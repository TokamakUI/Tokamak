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
import OpenCombineShim

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

  private var sceneSizeCancellable: AnyCancellable?

  private var isReconciling = false
  /// The identifiers for each `Fiber` that changed state during the last run loop.
  ///
  /// The reconciler loop starts at the root of the `View` hierarchy
  /// to ensure all preference values are passed down correctly.
  /// To help mitigate performance issues related to this, we only perform reconcile
  /// checks when we reach a changed `Fiber`.
  private var changedFibers = Set<ObjectIdentifier>()
  public var afterReconcileActions = [() -> ()]()

  struct RootView<Content: View>: View {
    let content: Content
    let reconciler: FiberReconciler<Renderer>

    var environment: EnvironmentValues {
      var environment = reconciler.renderer.defaultEnvironment
      environment.measureText = reconciler.renderer.measureText
      environment.measureImage = reconciler.renderer.measureImage
      environment.afterReconcile = reconciler.afterReconcile
      return environment
    }

    var body: some View {
      RootLayout(renderer: reconciler.renderer).callAsFunction {
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
      renderer.sceneSize.value
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
    var view = RootView(content: view, reconciler: self)
    current = .init(
      &view,
      element: renderer.rootElement,
      parent: nil,
      elementParent: nil,
      preferenceParent: nil,
      elementIndex: 0,
      traits: nil,
      reconciler: self
    )
    // Start by building the initial tree.
    alternate = current.createAndBindAlternate?()

    sceneSizeCancellable = renderer.sceneSize.removeDuplicates().sink { [weak self] _ in
      guard let self = self else { return }
      self.fiberChanged(self.current)
    }
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
    environment.measureImage = renderer.measureImage
    environment.afterReconcile = afterReconcile
    var app = app
    current = .init(
      &app,
      rootElement: renderer.rootElement,
      rootEnvironment: environment,
      reconciler: self
    )
    // Start by building the initial tree.
    alternate = current.createAndBindAlternate?()

    sceneSizeCancellable = renderer.sceneSize.removeDuplicates().sink { [weak self] _ in
      guard let self = self else { return }
      self.fiberChanged(self.current)
    }
  }

  /// A visitor that performs each pass used by the `FiberReconciler`.
  final class ReconcilerVisitor: AppVisitor, SceneVisitor, ViewVisitor {
    let root: Fiber
    /// Any `Fiber`s that changed state during the last run loop.
    let changedFibers: Set<ObjectIdentifier>
    unowned let reconciler: FiberReconciler
    var mutations = [Mutation<Renderer>]()

    init(root: Fiber, changedFibers: Set<ObjectIdentifier>, reconciler: FiberReconciler) {
      self.root = root
      self.changedFibers = changedFibers
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
      let rootResult = TreeReducer.Result(
        fiber: alternateRoot, // The alternate is the WIP node.
        visitChildren: visitChildren,
        parent: nil,
        child: alternateRoot?.child,
        alternateChild: root.child,
        elementIndices: [:],
        nextTraits: .init()
      )
      reconciler.caches.clear()
      for pass in reconciler.passes {
        pass.run(
          in: reconciler,
          root: rootResult,
          changedFibers: changedFibers,
          caches: reconciler.caches
        )
      }
      mutations = reconciler.caches.mutations
    }
  }

  func afterReconcile(_ action: @escaping () -> ()) {
    guard isReconciling == true
    else {
      action()
      return
    }
    afterReconcileActions.append(action)
  }

  /// Called by any `Fiber` that experiences a state change.
  ///
  /// Reconciliation only runs after every change during the current run loop has been performed.
  func fiberChanged(_ fiber: Fiber) {
    guard let alternate = fiber.alternate ?? fiber.createAndBindAlternate?()
    else { return }
    let shouldSchedule = changedFibers.isEmpty
    changedFibers.insert(ObjectIdentifier(alternate))
    if shouldSchedule {
      renderer.schedule { [weak self] in
        self?.reconcile()
      }
    }
  }

  /// Perform each `FiberReconcilerPass` given the `changedFibers`.
  ///
  /// A `reconcile()` call is queued from `fiberChanged` once per run loop.
  func reconcile() {
    isReconciling = true
    let changedFibers = changedFibers
    self.changedFibers.removeAll()
    // Create a list of mutations.
    let visitor = ReconcilerVisitor(root: current, changedFibers: changedFibers, reconciler: self)
    switch current.content {
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
    let alternate = alternate
    self.alternate = current
    current = alternate

    isReconciling = false

    for action in afterReconcileActions {
      action()
    }
  }
}

public extension EnvironmentValues {
  private enum AfterReconcileKey: EnvironmentKey {
    static let defaultValue: (@escaping () -> ()) -> () = { _ in }
  }

  var afterReconcile: (@escaping () -> ()) -> () {
    get { self[AfterReconcileKey.self] }
    set { self[AfterReconcileKey.self] = newValue }
  }
}
