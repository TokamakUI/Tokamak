//
//  File.swift
//
//
//  Created by Carson Katri on 2/15/22.
//

import Foundation

final class RootLayoutComputer: LayoutComputer {
  let sceneSize: CGSize

  init(sceneSize: CGSize) {
    self.sceneSize = sceneSize
  }

  func proposeSize<V>(for child: V, at index: Int) -> CGSize where V: View {
    sceneSize
  }

  func position(_ child: LayoutContext.Child, in context: LayoutContext) -> CGPoint {
    .init(
      x: sceneSize.width / 2 - child.dimensions[HorizontalAlignment.center],
      y: sceneSize.height / 2 - child.dimensions[VerticalAlignment.center]
    )
  }

  func requestSize(in context: LayoutContext) -> CGSize {
    sceneSize
  }
}

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

  struct RootView<Content: View>: View {
    let content: Content
    let renderer: Renderer

    var body: some View {
      content
        .environmentValues(renderer.defaultEnvironment)
    }

    static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
      .init(
        inputs: inputs,
        layoutComputer: RootLayoutComputer(sceneSize: inputs.view.renderer.sceneSize)
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
      var elementIndices: [ObjectIdentifier: Int]

      // For reducing
      var lastSibling: Result?
      var nextExisting: Fiber?
      var nextExistingAlternate: Fiber?

      init(
        fiber: Fiber?,
        visitChildren: @escaping (TreeReducer.Visitor) -> (),
        parent: Result?,
        child: Fiber?,
        alternateChild: Fiber?,
        newData: Renderer.ElementType.Data? = nil,
        elementIndices: [ObjectIdentifier: Int]
      ) {
        self.fiber = fiber
        self.visitChildren = visitChildren
        self.parent = parent
        nextExisting = child
        nextExistingAlternate = alternateChild
        self.newData = newData
        self.elementIndices = elementIndices
      }
    }

    static func reduce<V>(into partialResult: inout Result, nextView: V) where V: View {
      // Create the node and its element.
      var nextView = nextView
      let resultChild: Result
      if let existing = partialResult.nextExisting {
        // If a fiber already exists, simply update it with the new view.
        let key: ObjectIdentifier?
        if let elementParent = existing.elementParent {
          key = ObjectIdentifier(elementParent)
        } else {
          key = nil
        }
        let newData = existing.update(
          with: &nextView,
          elementIndex: key.map { partialResult.elementIndices[$0, default: 0] }
        )
        resultChild = Result(
          fiber: existing,
          visitChildren: nextView._visitChildren,
          parent: partialResult,
          child: existing.child,
          alternateChild: existing.alternate?.child,
          newData: newData,
          elementIndices: partialResult.elementIndices
        )
        partialResult.nextExisting = existing.sibling

        // If this fiber has an element, increment the elementIndex for its parent.
        if let key = key,
           existing.element != nil
        {
          partialResult.elementIndices[key] = partialResult.elementIndices[key, default: 0] + 1
        }
      } else {
        let elementParent = partialResult.fiber?.element != nil
          ? partialResult.fiber
          : partialResult.fiber?.elementParent
        let key: ObjectIdentifier?
        if let elementParent = elementParent {
          key = ObjectIdentifier(elementParent)
        } else {
          key = nil
        }
        // Otherwise, create a new fiber for this child.
        let fiber = Fiber(
          &nextView,
          element: partialResult.nextExistingAlternate?.element,
          parent: partialResult.fiber,
          elementParent: elementParent,
          elementIndex: key.map { partialResult.elementIndices[$0, default: 0] },
          reconciler: partialResult.fiber?.reconciler
        )
        // If a fiber already exists for an alternate, link them.
        if let alternate = partialResult.nextExistingAlternate {
          fiber.alternate = alternate
          partialResult.nextExistingAlternate = alternate.sibling
        }
        // If this fiber has an element, increment the elementIndex for its parent.
        if let key = key,
           fiber.element != nil
        {
          partialResult.elementIndices[key] = partialResult.elementIndices[key, default: 0] + 1
        }
        resultChild = Result(
          fiber: fiber,
          visitChildren: nextView._visitChildren,
          parent: partialResult,
          child: nil,
          alternateChild: fiber.alternate?.child,
          elementIndices: partialResult.elementIndices
        )
      }
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
        alternateChild: currentRoot.child,
        elementIndices: [:]
      )
      var node = rootResult

      /// A dictionary keyed by the unique ID of an element, with a value indicating what index
      /// we are currently at. This ensures we place children in the correct order, even if they are
      /// at different levels in the `View` tree.
      var elementIndices = [ObjectIdentifier: Int]()

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
          } else if let newData = node.newData,
                    newData != element.data
          {
            // This is the same type of view, but its backing data has changed.
            mutations.append(.update(previous: element, newData: newData))
          }
        }
      }

      /// Request a size for the view on the way back up the tree.
      func layout(_ node: Fiber) {
        // FIXME: Add alignmentGuide modifier to override defaults and pass the correct guide data.
        if let element = node.element {
          let elementIndex = node.elementIndex ?? 0
          // Fulfill the layout requests.
          let context = LayoutContext(children: node.layoutRequests.map(\.child))
          for request in node.layoutRequests {
            request.onLayout(node.outputs.layoutComputer.position(
              request.child, in: context
            ))
          }
          node.layoutRequests = []
          node.alternate?.layoutRequests = []
          // Compute our size in the context.
          let size = node.outputs.layoutComputer.requestSize(in: context)
          let dimensions = ViewDimensions(
            origin: .zero, size: size, alignmentGuides: [:]
          )
          // We enqueue our positioning request, but do not perform it until
          // all children of the elementParent are processed.
          node.elementParent?.enqueueLayoutRequest(
            dimensions,
            at: elementIndex
          ) { [weak self, weak node, weak element] origin in
            let dimensions = ViewDimensions(
              origin: origin,
              size: size,
              alignmentGuides: [:]
            )
            if dimensions != node?.alternate?.dimensions,
               let element = element
            {
              self?.mutations.append(.layout(element: element, dimensions: dimensions))
            }
            node?.dimensions = dimensions
            node?.alternate?.dimensions = dimensions
          }
        }
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

          // We call layout when we reach the bottommost view.
          if let fiber = node.fiber {
            layout(fiber)
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
            guard let parent = node.parent else { return }
            // We also call layout when we are walking back up the tree.
            if let fiber = parent.fiber {
              layout(fiber)
            }
            // When we walk back to the root, exit
            guard parent !== currentRoot.alternate else { return }
            node = parent
          }
          // Walk across to the sibling, and repeat.
          // swiftlint:disable:next force_unwrap
          node = node.sibling!
        }
      }
      mainLoop()

      // We continue afterwards to lay out any parents that may have pending layout requests
      // up the entire tree.
      var layoutNode = node.fiber
      while let current = layoutNode {
        layout(current)
        layoutNode = current.elementParent
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
