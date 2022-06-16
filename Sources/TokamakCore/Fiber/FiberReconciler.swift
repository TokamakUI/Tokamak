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

  struct RootView<Content: View>: View {
    let content: Content
    let renderer: Renderer

    var environment: EnvironmentValues {
      var environment = renderer.defaultEnvironment
      environment.measureText = renderer.measureText
      return environment
    }

    var body: some View {
      content
        .environmentValues(environment)
    }
  }

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
    var view = RootView(content: view, renderer: renderer)
    current = .init(
      &view,
      element: renderer.rootElement,
      parent: nil,
      elementParent: nil,
      elementIndex: 0,
      reconciler: self
    )
    // Start by building the initial tree.
    alternate = current.createAndBindAlternate?()
    reconcile(from: current)
  }

  public init<A: App>(_ renderer: Renderer, _ app: A) {
    self.renderer = renderer
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

  final class ReconcilerVisitor: AppVisitor, SceneVisitor, ViewVisitor {
    unowned let reconciler: FiberReconciler<Renderer>
    /// The current, mounted `Fiber`.
    var currentRoot: Fiber
    var mutations = [Mutation<Renderer>]()

    init(root: Fiber, reconciler: FiberReconciler<Renderer>) {
      self.reconciler = reconciler
      currentRoot = root
    }

    func visit<V>(_ view: V) where V: View {
      visitAny(view, visitChildren: reconciler.renderer.viewVisitor(for: view))
    }

    func visit<S>(_ scene: S) where S: Scene {
      visitAny(scene, visitChildren: scene._visitChildren)
    }

    func visit<A>(_ app: A) where A: App {
      visitAny(app, visitChildren: { $0.visit(app.body) })
    }

    /// Walk the current tree, recomputing at each step to check for discrepancies.
    ///
    /// Parent-first depth-first traversal.
    /// Take this `View` tree for example.
    /// ```swift
    /// VStack {
    ///   HStack {
    ///     Text("A")
    ///     Text("B")
    ///   }
    ///   Text("C")
    /// }
    /// ```
    /// Basically, we read it like this:
    /// 1. `VStack` has children, so we go to it's first child, `HStack`.
    /// 2. `HStack` has children, so we go further to it's first child, `Text`.
    /// 3. `Text` has no child, but has a sibling, so we go to that.
    /// 4. `Text` has no child and no sibling, so we return to the `HStack`.
    /// 5. We've already read the children, so we look for a sibling, `Text`.
    /// 6. `Text` has no children and no sibling, so we return to the `VStack.`
    /// We finish once we've returned to the root element.
    /// ```
    ///    ┌──────┐
    ///    │VStack│
    ///    └──┬───┘
    ///   ▲ 1 │
    ///   │   └──►┌──────┐
    ///   │       │HStack│
    ///   │     ┌─┴───┬──┘
    ///   │     │   ▲ │ 2
    ///   │     │   │ │  ┌────┐
    ///   │     │   │ └─►│Text├─┐
    /// 6 │     │ 4 │    └────┘ │
    ///   │     │   │           │ 3
    ///   │   5 │   │    ┌────┐ │
    ///   │     │   └────┤Text│◄┘
    ///   │     │        └────┘
    ///   │     │
    ///   │     └►┌────┐
    ///   │       │Text│
    ///   └───────┴────┘
    /// ```
    private func visitAny(
      _ value: Any,
      visitChildren: @escaping (TreeReducer.SceneVisitor) -> ()
    ) {
      let alternateRoot: Fiber?
      if let alternate = currentRoot.alternate {
        alternateRoot = alternate
      } else {
        alternateRoot = currentRoot.createAndBindAlternate?()
      }
      let rootResult = TreeReducer.Result(
        fiber: alternateRoot, // The alternate is the WIP node.
        visitChildren: visitChildren,
        parent: nil,
        child: alternateRoot?.child,
        alternateChild: currentRoot.child,
        elementIndices: [:]
      )
      var node = rootResult

      /// A dictionary keyed by the unique ID of an element, with a value indicating what index
      /// we are currently at. This ensures we place children in the correct order, even if they are
      /// at different levels in the `View` tree.
      var elementIndices = [ObjectIdentifier: Int]()
      /// The `Cache` for a fiber's layout.
      var caches = [ObjectIdentifier: Any]()
      /// The `LayoutSubviews` for each fiber.
      var layoutSubviews = [ObjectIdentifier: LayoutSubviews]()
      /// The (potentially nested) children of an `elementParent` with `element` values in order.
      /// Used to position children in the correct order.
      var elementChildren = [ObjectIdentifier: [Fiber]]()

      /// Compare `node` with its alternate, and add any mutations to the list.
      func reconcile(_ node: TreeReducer.Result) {
        if let element = node.fiber?.element,
           let index = node.fiber?.elementIndex,
           let parent = node.fiber?.elementParent?.element
        {
          if node.fiber?.alternate == nil { // This didn't exist before (no alternate)
            mutations.append(.insert(element: element, parent: parent, index: index))
          } else if node.fiber?.typeInfo?.type != node.fiber?.alternate?.typeInfo?.type,
                    let previous = node.fiber?.alternate?.element
          {
            // This is a completely different type of view.
            mutations.append(.replace(parent: parent, previous: previous, replacement: element))
          } else if let newContent = node.newContent,
                    newContent != element.content
          {
            // This is the same type of view, but its backing data has changed.
            mutations.append(.update(
              previous: element,
              newContent: newContent,
              geometry: node.fiber?.geometry ?? .init(
                origin: .init(origin: .zero),
                dimensions: .init(size: .zero, alignmentGuides: [:])
              )
            ))
          }
        }
      }

      /// Request a size from the fiber's `elementParent`.
      func sizeThatFits(_ node: Fiber, proposal: ProposedViewSize) {
        guard node.element != nil
        else { return }

        let key = ObjectIdentifier(node)

        // Compute our required size.
        // This does not have to respect the elementParent's proposed size.
        let subviews = layoutSubviews[key, default: .init(node)]
        var cache = caches[key, default: node.makeCache(subviews: subviews)]
        let size = node.sizeThatFits(
          proposal: proposal,
          subviews: subviews,
          cache: &cache
        )
        caches[key] = cache
        let dimensions = ViewDimensions(size: size, alignmentGuides: [:])

        // Update our geometry
        node.geometry = .init(
          origin: node.geometry?.origin ?? .init(origin: .zero),
          dimensions: dimensions
        )
      }

      /// The main reconciler loop.
      func mainLoop() {
        while true {
          // If this fiber has an element, set its `elementIndex`
          // and increment the `elementIndices` value for its `elementParent`.
          if node.fiber?.element != nil,
             let elementParent = node.fiber?.elementParent
          {
            let key = ObjectIdentifier(elementParent)
            node.fiber?.elementIndex = elementIndices[key, default: 0]
            elementIndices[key] = elementIndices[key, default: 0] + 1
          }

          // Perform work on the node.
          reconcile(node)

          // Ensure the TreeReducer can access the `elementIndices`.
          node.elementIndices = elementIndices

          // Compute the children of the node.
          let reducer = TreeReducer.SceneVisitor(initialResult: node)
          node.visitChildren(reducer)

          if reconciler.renderer.useDynamicLayout,
             let fiber = node.fiber
          {
            if let element = fiber.element,
               let elementParent = fiber.elementParent
            {
              let parentKey = ObjectIdentifier(elementParent)
              elementChildren[parentKey] = elementChildren[parentKey, default: []] + [fiber]
              var subviews = layoutSubviews[parentKey, default: .init(elementParent)]
              let key = ObjectIdentifier(fiber)
              subviews.storage.append(LayoutSubview(
                id: ObjectIdentifier(node),
                sizeThatFits: { [weak fiber] in
                  guard let fiber = fiber else { return .zero }
                  let subviews = layoutSubviews[key, default: .init(fiber)]
                  var cache = caches[key, default: fiber.makeCache(subviews: subviews)]
                  let size = fiber.sizeThatFits(
                    proposal: $0,
                    subviews: subviews,
                    cache: &cache
                  )
                  caches[key] = cache
                  return size
                },
                dimensions: { [weak fiber] in
                  guard let fiber = fiber else { return .init(size: .zero, alignmentGuides: [:]) }
                  let subviews = layoutSubviews[key, default: .init(fiber)]
                  var cache = caches[key, default: fiber.makeCache(subviews: subviews)]
                  let size = fiber.sizeThatFits(
                    proposal: $0,
                    subviews: subviews,
                    cache: &cache
                  )
                  caches[key] = cache
                  // TODO: Add `alignmentGuide` modifier and pass into `ViewDimensions`
                  return ViewDimensions(size: size, alignmentGuides: [:])
                },
                place: { [weak self, weak fiber, weak element] position, anchor, proposal in
                  guard let self = self, let fiber = fiber, let element = element else { return }
                  var cache = caches[key, default: fiber.makeCache(subviews: subviews)]
                  let dimensions = ViewDimensions(
                    size: fiber.sizeThatFits(
                      proposal: proposal,
                      subviews: layoutSubviews[key, default: .init(fiber)],
                      cache: &cache
                    ),
                    alignmentGuides: [:]
                  )
                  caches[key] = cache
                  let geometry = ViewGeometry(
                    // Shift to the anchor point in the parent's coordinate space.
                    origin: .init(origin: .init(
                      x: position.x - (dimensions.width * anchor.x),
                      y: position.y - (dimensions.height * anchor.y)
                    )),
                    dimensions: dimensions
                  )
                  // Push a layout mutation if needed.
                  if geometry != fiber.alternate?.geometry {
                    self.mutations.append(.layout(element: element, geometry: geometry))
                  }
                  // Update ours and our alternate's geometry
                  fiber.geometry = geometry
                  fiber.alternate?.geometry = geometry
                }
              ))
              layoutSubviews[parentKey] = subviews
            }
          }

          // Setup the alternate if it doesn't exist yet.
          if node.fiber?.alternate == nil {
            _ = node.fiber?.createAndBindAlternate?()
          }

          // Walk all down all the way into the deepest child.
          if let child = reducer.result.child {
            node = child
            continue
          } else if let alternateChild = node.fiber?.alternate?.child {
            // The alternate has a child that no longer exists.
            walk(alternateChild) { node in
              if let element = node.element,
                 let parent = node.elementParent?.element
              {
                // Removals must happen in reverse order, so a child element
                // is removed before its parent.
                self.mutations.insert(.remove(element: element, parent: parent), at: 0)
              }
              return true
            }
          }
          if reducer.result.child == nil {
            // Make sure we clear the child if there was none
            node.fiber?.child = nil
            node.fiber?.alternate?.child = nil
          }

          // If we've made it back to the root, then exit.
          if node === rootResult {
            return
          }

          // Now walk back up the tree until we find a sibling.
          while node.sibling == nil {
            var alternateSibling = node.fiber?.alternate?.sibling
            while alternateSibling !=
              nil
            { // The alternate had siblings that no longer exist.
              if let element = alternateSibling?.element,
                 let parent = alternateSibling?.elementParent?.element
              {
                // Removals happen in reverse order, so a child element is removed before
                // its parent.
                mutations.insert(.remove(element: element, parent: parent), at: 0)
              }
              alternateSibling = alternateSibling?.sibling
            }
            guard let parent = node.parent else { return }
            // When we walk back to the root, exit
            guard parent !== currentRoot.alternate else { return }
            node = parent
          }

          // Walk across to the sibling, and repeat.
          node = node.sibling!
        }
      }
      mainLoop()

      // Layout from the top down.
      if reconciler.renderer.useDynamicLayout,
         let root = rootResult.fiber
      {
        var fiber = root

        func layoutLoop() {
          while true {
            sizeThatFits(
              fiber,
              proposal: .init(
                fiber.elementParent?.geometry?.dimensions.size ?? reconciler.renderer.sceneSize
              )
            )

            if let child = fiber.child {
              fiber = child
              continue
            }

            while fiber.sibling == nil {
              // Before we walk back up, place our children in our bounds.
              let key = ObjectIdentifier(fiber)
              let subviews = layoutSubviews[key, default: .init(fiber)]
              var cache = caches[key, default: fiber.makeCache(subviews: subviews)]
              fiber.placeSubviews(
                in: .init(
                  origin: .zero,
                  size: fiber.geometry?.dimensions.size ?? reconciler.renderer.sceneSize
                ),
                proposal: .init(
                  fiber.elementParent?.geometry?.dimensions.size ?? reconciler.renderer.sceneSize
                ),
                subviews: subviews,
                cache: &cache
              )
              caches[key] = cache
              // Exit at the top of the View tree
              guard let parent = fiber.parent else { return }
              guard parent !== currentRoot.alternate else { return }
              // Walk up to the next parent.
              fiber = parent
            }

            let key = ObjectIdentifier(fiber)
            let subviews = layoutSubviews[key, default: .init(fiber)]
            var cache = caches[key, default: fiber.makeCache(subviews: subviews)]
            fiber.placeSubviews(
              in: .init(
                origin: .zero,
                size: fiber.geometry?.dimensions.size ?? reconciler.renderer.sceneSize
              ),
              proposal: .init(
                fiber.elementParent?.geometry?.dimensions.size ?? reconciler.renderer.sceneSize
              ),
              subviews: subviews,
              cache: &cache
            )
            caches[key] = cache

            fiber = fiber.sibling!
          }
        }
        layoutLoop()

        var layoutNode: Fiber? = fiber
        while let fiber = layoutNode {
          let key = ObjectIdentifier(fiber)
          let subviews = layoutSubviews[key, default: .init(fiber)]
          var cache = caches[key, default: fiber.makeCache(subviews: subviews)]
          fiber.placeSubviews(
            in: .init(
              origin: .zero,
              size: fiber.geometry?.dimensions.size ?? reconciler.renderer.sceneSize
            ),
            proposal: .init(
              fiber.elementParent?.geometry?.dimensions.size ?? reconciler.renderer.sceneSize
            ),
            subviews: subviews,
            cache: &cache
          )
          caches[key] = cache

          layoutNode = fiber.parent
        }
      }
    }
  }

  func reconcile(from root: Fiber) {
    // Create a list of mutations.
    let visitor = ReconcilerVisitor(root: root, reconciler: self)
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
    let child = root.child
    root.child = root.alternate?.child
    root.alternate?.child = child
  }
}
