//
//  File.swift
//
//
//  Created by Carson Katri on 2/15/22.
//

public final class FiberReconciler<Renderer: FiberRenderer> {
  @_spi(TokamakCore) public var current: Fiber!
  private var alternate: Fiber!
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
      var elementIndices = [ObjectIdentifier: Int]()

      func reconcile(_ node: TreeReducer.Result) {
        // Compare `node` and its alternate.
        if let element = node.fiber?.element,
           let parent = node.fiber?.elementParent?.element
        {
          let key = ObjectIdentifier(parent)
          let index = elementIndices[key, default: 0]
          if node.fiber?.alternate == nil { // This didn't exist before (no alternate)
            mutations.append(.insert(element: element, parent: parent, index: index))
          } else if let newData = node.newData,
                    newData != element.data
          { // This changed.
            mutations.append(.update(previous: element, newData: newData))
          }
          elementIndices[key] = index + 1
        }
      }

      while true {
        // Perform work on the node
        reconcile(node)
        let reducer = TreeReducer.Visitor(initialResult: node)
        node.visitChildren(reducer)

        // Setup the alternate if it doesn't exist yet.
        if node.fiber?.alternate == nil {
          node.fiber?.createAndBindAlternate?()
        }

        // Walk into the child
        if let child = reducer.result.child {
          node = child
          continue
        } else if let alternateChild = node.fiber?.alternate?.child {
          walk(alternateChild) { node in
            if let element = node.element,
               let parent = node.elementParent?.element
            {
              // The alternate has a child that no longer exists
              self.mutations.append(.remove(element: element, parent: parent))
            }
            return true
          }
        }
        if reducer.result.child == nil {
          node.fiber?.child = nil // Make sure we clear the child if there was none
        }

        // When we walk back to the root, exit
        if node === rootResult {
          return
        }
        // Walk back up until we find a sibling
        while node.sibling == nil {
          var alternateSibling = node.fiber?.alternate?.sibling
          while alternateSibling != nil { // The alternate had siblings that no longer exist.
            if let element = alternateSibling?.element,
               let parent = alternateSibling?.elementParent?.element
            {
              mutations.append(.remove(element: element, parent: parent))
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
        // Walk the sibling
        // swiftlint:disable:next force_unwrap
        node = node.sibling!
      }
    }
  }

  func reconcile(from root: Fiber) {
    let visitor = ReconcilerVisitor(root: root, reconciler: self)
    root.visitView(visitor)
    // Apply mutations to the rendered output.
    renderer.commit(visitor.mutations)

    // Swap the root out for its alternate.
    let child = root.child
    root.child = root.alternate?.child
    root.alternate?.child = child
  }
}
