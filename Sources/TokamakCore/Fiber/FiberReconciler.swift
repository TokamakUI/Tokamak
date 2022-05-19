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

/// A reconciler modeled after React's [Fiber reconciler](https://reactjs.org/docs/faq-internals.html#what-is-react-fiber)
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

  public init<V: View>(_ renderer: Renderer, _ view: V) {
    self.renderer = renderer
    var view = view.environmentValues(renderer.defaultEnvironment)
    current = .init(
      &view,
      element: renderer.rootElement,
      parent: nil,
      elementParent: nil,
      childIndex: 0,
      reconciler: self
    )
    // Start by building the initial tree.
    alternate = current.createAndBindAlternate?()
    reconcile(from: current)
  }

  /// Convert the first level of children of a `View` into a linked list of `Fiber`s.
  struct TreeReducer: ViewReducer {
    final class Result {
      // For references
      let fiber: Fiber?
      let visitChildren: (TreeReducer.Visitor) -> ()
      unowned var parent: Result?
      var child: Result?
      var sibling: Result?
      var newData: Renderer.ElementType.Data?

      // For reducing
      var childrenCount: Int = 0
      var lastSibling: Result?
      var nextExisting: Fiber?
      var nextExistingAlternate: Fiber?

      init(
        fiber: Fiber?,
        visitChildren: @escaping (TreeReducer.Visitor) -> (),
        parent: Result?,
        child: Fiber?,
        alternateChild: Fiber?,
        newData: Renderer.ElementType.Data? = nil
      ) {
        self.fiber = fiber
        self.visitChildren = visitChildren
        self.parent = parent
        nextExisting = child
        nextExistingAlternate = alternateChild
        self.newData = newData
      }
    }

    static func reduce<V>(into partialResult: inout Result, nextView: V) where V: View {
      // Create the node and its element.
      var nextView = nextView
      let resultChild: Result
      if let existing = partialResult.nextExisting {
        // If a fiber already exists, simply update it with the new view.
        let newData = existing.update(
          with: &nextView,
          childIndex: partialResult.childrenCount
        )
        resultChild = Result(
          fiber: existing,
          visitChildren: nextView._visitChildren,
          parent: partialResult,
          child: existing.child,
          alternateChild: existing.alternate?.child,
          newData: newData
        )
        partialResult.nextExisting = existing.sibling
      } else {
        // Otherwise, create a new fiber for this child.
        let fiber = Fiber(
          &nextView,
          element: partialResult.nextExistingAlternate?.element,
          parent: partialResult.fiber,
          elementParent: partialResult.fiber?.element != nil
            ? partialResult.fiber
            : partialResult.fiber?.elementParent,
          childIndex: partialResult.childrenCount,
          reconciler: partialResult.fiber?.reconciler
        )
        // If a fiber already exists for an alternate, link them.
        if let alternate = partialResult.nextExistingAlternate {
          fiber.alternate = alternate
          partialResult.nextExistingAlternate = alternate.sibling
        }
        resultChild = Result(
          fiber: fiber,
          visitChildren: nextView._visitChildren,
          parent: partialResult,
          child: nil,
          alternateChild: fiber.alternate?.child
        )
      }
      // Keep track of the index of the child so the LayoutComputer can propose sizes.
      partialResult.childrenCount += 1
      // Get the last child element we've processed, and add the new child as its sibling.
      if let lastSibling = partialResult.lastSibling {
        lastSibling.fiber?.sibling = resultChild.fiber
        lastSibling.sibling = resultChild
      } else {
        // Otherwise setup the first child
        partialResult.fiber?.child = resultChild.fiber
        partialResult.child = resultChild
      }
      partialResult.lastSibling = resultChild
    }
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
        fiber: alternateRoot, // The alternate is the WIP node.
        visitChildren: view._visitChildren,
        parent: nil,
        child: alternateRoot?.child,
        alternateChild: currentRoot.child
      )
      var node = rootResult

      /// A dictionary keyed by the unique ID of an element, with a value indicating what index
      /// we are currently at. This ensures we place children in the correct order, even if they are
      /// at different levels in the `View` tree.
      var elementIndices = [ObjectIdentifier: Int]()

      /// Compare `node` with its alternate, and add any mutations to the list.
      func reconcile(_ node: TreeReducer.Result) {
        if let element = node.fiber?.element,
           let parent = node.fiber?.elementParent?.element
        {
          let key = ObjectIdentifier(parent)
          let index = elementIndices[key, default: 0]
          if node.fiber?.alternate == nil { // This didn't exist before (no alternate)
            mutations.append(.insert(element: element, parent: parent, index: index))
          } else if node.fiber?.typeInfo?.type != node.fiber?.alternate?.typeInfo?.type,
                    let previous = node.fiber?.alternate?.element
          {
            // This is a completely different type of view.
            mutations.append(.replace(parent: parent, previous: previous, replacement: element))
          } else if let newData = node.newData,
                    newData != element.data
          {
            // This is the same type of view, but its backing data has changed.
            mutations.append(.update(previous: element, newData: newData))
          }
          elementIndices[key] = index + 1
        }
      }

      // The main reconciler loop.
      while true {
        // Perform work on the node.
        reconcile(node)

        // Compute the children of the node.
        let reducer = TreeReducer.Visitor(initialResult: node)
        node.visitChildren(reducer)

        // Setup the alternate if it doesn't exist yet.
        if node.fiber?.alternate == nil {
          node.fiber?.createAndBindAlternate?()
        }

        // Walk all down all the way into the deepest child.
        if let child = reducer.result.child {
          node = child
          continue
        } else if let alternateChild = node.fiber?.alternate?.child {
          walk(alternateChild) { node in
            if let element = node.element,
               let parent = node.elementParent?.element
            {
              // The alternate has a child that no longer exists.
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
          // When we walk back to the root, exit
          guard let parent = node.parent,
                parent !== currentRoot.alternate
          else {
            return
          }
          node = parent
        }
        // Walk across to the sibling, and repeat.
        // swiftlint:disable:next force_unwrap
        node = node.sibling!
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
