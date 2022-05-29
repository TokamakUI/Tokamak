// Copyright 2021 Tokamak contributors
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
  @_spi(TokamakCore) public var current: Fiber!
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

    static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
      .init(
        inputs: inputs,
        layoutComputer: { _ in RootLayoutComputer(sceneSize: inputs.content.renderer.sceneSize) }
      )
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

  final class ReconcilerVisitor: ViewVisitor {
    unowned let reconciler: FiberReconciler<Renderer>
    /// The current, mounted `Fiber`.
    var currentRoot: Fiber
    var mutations = [Mutation<Renderer>]()

    init(root: Fiber, reconciler: FiberReconciler<Renderer>) {
      self.reconciler = reconciler
      currentRoot = root
    }

    /// A `ViewVisitor` that proposes a size for the `View` represented by the fiber `node`.
    struct ProposeSizeVisitor: ViewVisitor {
      let node: Fiber
      let layoutContexts: [ObjectIdentifier: LayoutContext]

      func visit<V>(_ view: V) where V: View {
        // Ask the parent for a size.
        let proposedSize = node.elementParent?.outputs.layoutComputer.proposeSize(
          for: view,
          at: node.elementIndex ?? 0,
          in: node.elementParent.flatMap { layoutContexts[ObjectIdentifier($0)] }
            ?? .init(children: [])
        ) ?? .zero
        // Make our layout computer using that size.
        node.outputs.layoutComputer = node.outputs.makeLayoutComputer(proposedSize)
        node.alternate?.outputs.layoutComputer = node.outputs.layoutComputer
      }
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
    func visit<V>(_ view: V) where V: View {
      let alternateRoot: Fiber?
      if let alternate = currentRoot.alternate {
        alternateRoot = alternate
      } else {
        alternateRoot = currentRoot.createAndBindAlternate?()
      }
      let rootResult = TreeReducer.Result(
        reconciler: reconciler,
        fiber: alternateRoot, // The alternate is the WIP node.
        visitChildren: reconciler.renderer.viewVisitor(for: view),
        parent: nil,
        child: alternateRoot?.child,
        alternateChild: currentRoot.child,
        elementIndices: [:],
        layoutContexts: [:]
      )
      var node = rootResult

      /// A dictionary keyed by the unique ID of an element, with a value indicating what index
      /// we are currently at. This ensures we place children in the correct order, even if they are
      /// at different levels in the `View` tree.
      var elementIndices = [ObjectIdentifier: Int]()
      /// The `LayoutContext` for each parent view.
      var layoutContexts = [ObjectIdentifier: LayoutContext]()
      /// The children of an `elementParent` with `element`s in order.
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

      func proposeSize(for node: Fiber) {
        guard node.element != nil else { return }

        node.visitView(ProposeSizeVisitor(node: node, layoutContexts: layoutContexts))
      }

      func size(_ node: Fiber) {
        guard node.element != nil,
              let elementParent = node.elementParent
        else { return }

        let key = ObjectIdentifier(elementParent)
        let elementIndex = node.elementIndex ?? 0
        var parentContext = layoutContexts[key, default: .init(children: [])]

        // Compute our size and position in our context.
        let size = node.outputs.layoutComputer.requestSize(
          in: layoutContexts[ObjectIdentifier(node), default: .init(children: [])]
        )
        let dimensions = ViewDimensions(size: size, alignmentGuides: [:])
        let child = LayoutContext.Child(index: elementIndex, dimensions: dimensions)

        // Add ourself to the parent context.
        parentContext.children.append(child)
        layoutContexts[key] = parentContext

        // Update our geometry
        node.geometry = .init(
          origin: node.geometry?.origin ?? .init(origin: .zero),
          dimensions: dimensions
        )
      }

      /// Request a size and position from the parent on the way back up.
      func position(_ node: Fiber) {
        // FIXME: Add alignmentGuide modifier to override defaults and pass the correct guide data.
        guard let element = node.element,
              let elementParent = node.elementParent
        else { return }

        let key = ObjectIdentifier(elementParent)
        let elementIndex = node.elementIndex ?? 0
        let context = layoutContexts[key, default: .init(children: [])]

        guard let child = context.children.first(where: { $0.index == elementIndex })
        else { return }

        // Compute our position in the context.
        let position = elementParent.outputs.layoutComputer.position(child, in: context)
        let geometry = ViewGeometry(
          origin: .init(origin: position),
          dimensions: child.dimensions
        )

        // Push a layout mutation if needed.
        if geometry != node.alternate?.geometry {
          mutations.append(.layout(element: element, geometry: geometry))
        }
        // Update ours and our alternate's geometry
        node.geometry = geometry
        node.alternate?.geometry = geometry
      }

      /// The main reconciler loop.
      func mainLoop() {
        while true {
          // Perform work on the node.
          reconcile(node)

          node.elementIndices = elementIndices

          // Compute the children of the node.
          let reducer = TreeReducer.Visitor(initialResult: node)
          node.visitChildren(reducer)
          elementIndices = node.elementIndices

          // Propose sizes on the way down.
          if reconciler.renderer.shouldLayout,
             let fiber = node.fiber
          {
            proposeSize(for: fiber)
            if fiber.element != nil,
               let key = fiber.elementParent.map(ObjectIdentifier.init)
            {
              elementChildren[key] = elementChildren[key, default: []] + [fiber]
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
            node.fiber?.child = nil // Make sure we clear the child if there was none
          }

          // If we've made it back to the root, then exit.
          if node === rootResult {
            return
          }

          // Now walk back up the tree until we find a sibling.
          while node.sibling == nil {
            var alternateSibling = node.fiber?.alternate?.sibling
            while alternateSibling != nil { // The alternate had siblings that no longer exist.
              if let element = alternateSibling?.element,
                 let parent = alternateSibling?.elementParent?.element
              {
                // Removals happen in reverse order, so a child element is removed before
                // its parent.
                mutations.insert(.remove(element: element, parent: parent), at: 0)
              }
              alternateSibling = alternateSibling?.sibling
            }
            // We `size` and `position` when we are walking back up the tree.
            if reconciler.renderer.shouldLayout,
               let fiber = node.fiber
            {
              size(fiber)
              // Position the children in order.
              if let elementChildren = elementChildren[ObjectIdentifier(fiber)] {
                for elementChild in elementChildren {
                  position(elementChild)
                }
              }
            }
            guard let parent = node.parent else { return }
            // When we walk back to the root, exit
            guard parent !== currentRoot.alternate else { return }
            node = parent
          }

          // We `size` and `position` when we reach the bottommost view that has a sibling.
          // Otherwise, sizing takes place in the above loop.
          if reconciler.renderer.shouldLayout,
             let fiber = node.fiber
          {
            size(fiber)
            // Position the children in order.
            if let elementChildren = elementChildren[ObjectIdentifier(fiber)] {
              for elementChild in elementChildren {
                position(elementChild)
              }
            }
          }

          // Walk across to the sibling, and repeat.
          node = node.sibling!
        }
      }
      mainLoop()

      if reconciler.renderer.shouldLayout {
        // We continue to the very top to update all necessary positions.
        var layoutNode = node.fiber?.child
        while let current = layoutNode {
          // We only need to re-position, because the size can't change if no state changed.
          if let elementChildren = elementChildren[ObjectIdentifier(current)] {
            for elementChild in elementChildren {
              position(elementChild)
            }
          }
          if current.sibling != nil {
            // We also don't need to go deep into sibling children,
            // because child positioning is relative to the parent.
            layoutNode = current.sibling
          } else {
            layoutNode = current.parent
          }
        }
      }
    }
  }

  func reconcile(from root: Fiber) {
    // Create a list of mutations.
    let visitor = ReconcilerVisitor(root: root, reconciler: self)
    root.visitView(visitor)

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
