// Copyright 2022 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Created by Carson Katri on 2/15/22.
//

import Foundation

/// A reconciler modeled after React's
/// [Fiber reconciler](https://reactjs.org/docs/faq-internals.html#what-is-react-fiber)
public final class FiberReconciler<Renderer: FiberRenderer> {
  /// The root node in the `Fiber` tree that represents the `View`s currently rendered on screen.
  @_spi(TokamakCore)
  public var current: Fiber!

  /// The alternate of `current`, or the work in progress tree root.
  ///
  /// We must keep a strong reference to both the current and alternate tree roots,
  /// as they only keep weak references to each other.
  private var alternate: Fiber!

  /// The `FiberRenderer` used to create and update the `Element`s on screen.
  public let renderer: Renderer

  /// Enabled passes to run on each `reconcile(from:)` call.
  private let passes: [FiberReconcilerPass]

  private let caches: Caches

  struct RootView<Content: View>: View {
    let content: Content
    let renderer: Renderer

    var environment: EnvironmentValues {
      var environment = renderer.defaultEnvironment
      environment.measureText = renderer.measureText
      return environment
    }

    var body: some View {
      RootLayout(renderer: renderer).callAsFunction {
        content
          .environmentValues(environment)
      }
    }
  }

  /// The `Layout` container for the root of a `View` hierarchy.
  ///
  /// Simply places each `View` in the center of its bounds.
  struct RootLayout: Layout {
    let renderer: Renderer

    func sizeThatFits(
      proposal: ProposedViewSize,
      subviews: Subviews,
      cache: inout ()
    ) -> CGSize {
      renderer.sceneSize
    }

    func placeSubviews(
      in bounds: CGRect,
      proposal: ProposedViewSize,
      subviews: Subviews,
      cache: inout ()
    ) {
      for subview in subviews {
        subview.place(
          at: .init(x: bounds.midX, y: bounds.midY),
          anchor: .center,
          proposal: .init(width: bounds.width, height: bounds.height)
        )
      }
    }
  }

  public init<V: View>(_ renderer: Renderer, _ view: V) {
    self.renderer = renderer
    if renderer.useDynamicLayout {
      passes = [.reconcile, .layout]
    } else {
      passes = [.reconcile]
    }
    caches = Caches()
    var view = RootView(content: view, renderer: renderer)
    current = .init(
      &view,
      element: renderer.rootElement,
      parent: nil,
      elementParent: nil,
      elementIndex: 0,
      traits: nil,
      reconciler: self
    )
    // Start by building the initial tree.
    alternate = current.createAndBindAlternate?()
    reconcile(from: current)
  }

  public init<A: App>(_ renderer: Renderer, _ app: A) {
    self.renderer = renderer
    if renderer.useDynamicLayout {
      passes = [.reconcile, .layout]
    } else {
      passes = [.reconcile]
    }
    caches = Caches()
    var environment = renderer.defaultEnvironment
    environment.measureText = renderer.measureText
    var app = app
    current = .init(
      &app,
      rootElement: renderer.rootElement,
      rootEnvironment: environment,
      reconciler: self
    )
    // Start by building the initial tree.
    alternate = current.createAndBindAlternate?()
    reconcile(from: current)
  }

  /// A visitor that performs each pass used by the `FiberReconciler`.
  final class ReconcilerVisitor: AppVisitor, SceneVisitor, ViewVisitor {
    let root: Fiber
    let reconcileRoot: Fiber
    unowned let reconciler: FiberReconciler
    var mutations = [Mutation<Renderer>]()

    init(root: Fiber, reconcileRoot: Fiber, reconciler: FiberReconciler) {
      self.root = root
      self.reconcileRoot = reconcileRoot
      self.reconciler = reconciler
    }

    func visit<A>(_ app: A) where A: App {
      visitAny(app) { $0.visit(app.body) }
    }

    func visit<S>(_ scene: S) where S: Scene {
      visitAny(scene, scene._visitChildren)
    }

    func visit<V>(_ view: V) where V: View {
      visitAny(view, reconciler.renderer.viewVisitor(for: view))
    }

    private func visitAny(
      _ content: Any,
      _ visitChildren: @escaping (TreeReducer.SceneVisitor) -> ()
    ) {
      let alternateRoot: Fiber?
      if let alternate = root.alternate {
        alternateRoot = alternate
      } else {
        alternateRoot = root.createAndBindAlternate?()
      }
      let alternateReconcileRoot: Fiber?
      if let alternate = reconcileRoot.alternate {
        alternateReconcileRoot = alternate
      } else {
        alternateReconcileRoot = reconcileRoot.createAndBindAlternate?()
      }
      guard let alternateReconcileRoot = alternateReconcileRoot else { return }
      let rootResult = TreeReducer.Result(
        fiber: alternateRoot, // The alternate is the WIP node.
        visitChildren: visitChildren,
        parent: nil,
        child: alternateRoot?.child,
        alternateChild: root.child,
        elementIndices: [:],
        pendingTraits: .init()
      )
      reconciler.caches.clear()
      for pass in reconciler.passes {
        pass.run(
          in: reconciler,
          root: rootResult,
          reconcileRoot: alternateReconcileRoot,
          caches: reconciler.caches
        )
      }
      mutations = reconciler.caches.mutations
    }
  }

  func reconcile(from updateRoot: Fiber) {
    let root: Fiber
    if renderer.useDynamicLayout {
      // We need to re-layout from the top down when using dynamic layout.
      root = current
    } else {
      root = updateRoot
    }
    // Create a list of mutations.
    let visitor = ReconcilerVisitor(root: root, reconcileRoot: updateRoot, reconciler: self)
    switch root.content {
    case let .view(_, visit):
      visit(visitor)
    case let .scene(_, visit):
      visit(visitor)
    case let .app(_, visit):
      visit(visitor)
    case .none:
      break
    }

    // Apply mutations to the rendered output.
    renderer.commit(visitor.mutations)

    // Swap the root out for its alternate.
    // Essentially, making the work in progress tree the current,
    // and leaving the current available to be the work in progress
    // on our next update.
    if root === current {
      let alternate = alternate
      self.alternate = current
      current = alternate
    } else {
      let child = root.child
      root.child = root.alternate?.child
      root.alternate?.child = child
    }
  }
}
