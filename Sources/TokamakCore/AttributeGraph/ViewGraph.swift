//
//  File.swift
//
//
//  Created by Carson Katri on 2/3/22.
//

public protocol ViewVisitor {
  func visit<V: View>(_ view: V)
}

public extension View {
  func _visitChildren<V: ViewVisitor>(_ visitor: V) {
    visitor.visit(body)
  }
}

typealias ViewVisitorF<V: ViewVisitor> = (V) -> ()

protocol ViewReducer {
  associatedtype Result
  static func reduce<V: View>(into partialResult: inout Result, nextView: V)
  static func reduce<V: View>(partialResult: Result, nextView: V) -> Result
}

extension ViewReducer {
  static func reduce<V: View>(into partialResult: inout Result, nextView: V) {
    partialResult = Self.reduce(partialResult: partialResult, nextView: nextView)
  }

  static func reduce<V: View>(partialResult: Result, nextView: V) -> Result {
    var result = partialResult
    Self.reduce(into: &result, nextView: nextView)
    return result
  }
}

final class ReducerVisitor<R: ViewReducer>: ViewVisitor {
  var result: R.Result

  init(initialResult: R.Result) {
    result = initialResult
  }

  func visit<V>(_ view: V) where V: View {
    R.reduce(into: &result, nextView: view)
  }
}

extension ViewReducer {
  typealias Visitor = ReducerVisitor<Self>
}

/// An output from a `Renderer`.
public protocol Element: AnyObject {
  associatedtype Data: ElementData
  var data: Data { get }
  init(from data: Data)
  func update(with data: Data)
}

/// The data used to create an `Element`. We re-use `Element` instances, but can re-create and copy `ElementData` as often as needed.
public protocol ElementData: Equatable {
  init<V: View>(from primitiveView: V)
}

public protocol GraphRenderer {
  associatedtype ElementType: Element
  static func isPrimitive<V>(_ view: V) -> Bool where V: View
  func commit(_ mutations: [Mutation<Self>])
  var rootElement: ElementType { get }
  var defaultEnvironment: EnvironmentValues { get }
}

public extension GraphRenderer {
  var defaultEnvironment: EnvironmentValues { .init() }
}

public enum Mutation<Renderer: GraphRenderer> {
  case insert(
    element: Renderer.ElementType,
    parent: Renderer.ElementType,
    index: Int
  )
  case remove(element: Renderer.ElementType, parent: Renderer.ElementType?)
  case replace(
    parent: Renderer.ElementType,
    previous: Renderer.ElementType,
    replacement: Renderer.ElementType
  )
  case update(previous: Renderer.ElementType, newData: Renderer.ElementType.Data)
}

@_spi(TokamakCore) public extension Reconciler {
  final class ViewNode: CustomDebugStringConvertible {
    weak var reconciler: Reconciler<Renderer>?

    /// The underlying `View` instance.
    var view: Any!
    /// Outputs from evaluating `View._makeView`
    var outputs: ViewOutputs!
    /// A function to visit `view` generically.
    var visitView: ((ViewVisitor) -> ())!
    /// The identity of this `View`
    var id: Identity?
    /// The mounted element, if this is a Renderer primitive.
    var element: Renderer.ElementType?
    /// The first child node.
    var child: ViewNode?
    /// This node's right sibling.
    var sibling: ViewNode?
    /// An unowned reference to the parent node.
    unowned var parent: ViewNode?
    /// The nearest parent that can be mounted on.
    unowned var elementParent: ViewNode?
    /// The cached type information for the underlying `View`.
    var typeInfo: TypeInfo?
    /// Boxes that store `State` data.
    var state: [PropertyInfo: MutableStorage]!

    /// The WIP node if this is current, or the current node if this is WIP.
    weak var alternate: ViewNode?

    var createAndBindAlternate: (() -> ViewNode)?

    /// A box holding a value for an `@State` property wrapper.
    /// Will call `onSet` (usually a `Reconciler.reconcile` call) when updated.
    final class MutableStorage {
      private(set) var value: Any
      let onSet: () -> ()

      func setValue(_ newValue: Any, with transaction: Transaction) {
        value = newValue
        onSet()
      }

      init(initialValue: Any, onSet: @escaping () -> ()) {
        value = initialValue
        self.onSet = onSet
      }
    }

    public enum Identity: Hashable {
      case explicit(AnyHashable)
      case structural(index: Int)
    }

    init<V: View>(
      _ view: inout V,
      element: Renderer.ElementType?,
      parent: ViewNode?,
      elementParent: ViewNode?,
      childIndex: Int,
      reconciler: Reconciler<Renderer>?
    ) {
      self.reconciler = reconciler
      child = nil
      sibling = nil
      self.parent = parent
      self.elementParent = elementParent
      typeInfo = TokamakCore.typeInfo(of: V.self)

      let viewInputs = ViewInputs<V>(
        view: view,
        proposedSize: parent?.outputs.layoutComputer?.proposeSize(for: view, at: childIndex),
        environment: parent?.outputs.environment ?? .init(.init())
      )
      state = bindProperties(to: &view, typeInfo, viewInputs)
      self.view = view
      outputs = V._makeView(viewInputs)
      visitView = { [weak self] in
        guard let self = self else { return }
        // swiftlint:disable:next force_cast
        $0.visit(self.view as! V)
      }

      if let element = element {
        self.element = element
      } else if Renderer.isPrimitive(view) {
        self.element = .init(from: .init(from: view))
      }

      let alternateView = view
      createAndBindAlternate = {
        // Create the alternate lazily
        let alternate = ViewNode(
          bound: alternateView,
          alternate: self,
          outputs: self.outputs,
          typeInfo: self.typeInfo,
          element: self.element,
          parent: self.parent?.alternate,
          elementParent: self.elementParent?.alternate,
          reconciler: reconciler
        )
        self.alternate = alternate
        if self.parent?.child === self {
          self.parent?.alternate?.child = alternate // Link it with our parent's alternate.
        } else {
          // Find our left sibling.
          var node = self.parent?.child
          while node?.sibling !== self {
            guard node?.sibling != nil else { return alternate }
            node = node?.sibling
          }
          if node?.sibling === self {
            node?.alternate?.sibling = alternate // Link it with our left sibling's alternate.
          }
        }
        return alternate
      }
    }

    init<V: View>(
      bound view: V,
      alternate: ViewNode,
      outputs: ViewOutputs,
      typeInfo: TypeInfo?,
      element: Renderer.ElementType?,
      parent: Reconciler<Renderer>.ViewNode?,
      elementParent: ViewNode?,
      reconciler: Reconciler<Renderer>?
    ) {
      self.view = view
      self.alternate = alternate
      self.reconciler = reconciler
      self.element = element
      child = nil
      sibling = nil
      self.parent = parent
      self.elementParent = elementParent
      self.typeInfo = typeInfo
      self.outputs = outputs
      visitView = { [weak self] in
        guard let self = self else { return }
        // swiftlint:disable:next force_cast
        $0.visit(self.view as! V)
      }
    }

    private func bindProperties<V: View>(
      to view: inout V,
      _ typeInfo: TypeInfo?,
      _ viewInputs: ViewInputs<V>
    ) -> [PropertyInfo: MutableStorage] {
      guard let typeInfo = typeInfo else { return [:] }

      var state: [PropertyInfo: MutableStorage] = [:]
      for property in typeInfo.properties where property.type is DynamicProperty.Type {
        var value = property.get(from: view)
        if var storage = value as? WritableValueStorage {
          let box = MutableStorage(initialValue: storage.anyInitialValue, onSet: { [weak self] in
            guard let self = self else { return }
            self.reconciler?.reconcile(from: self)
//            self.flip()
          })
          state[property] = box
          storage.getter = { box.value }
          storage.setter = { box.setValue($0, with: $1) }
          value = storage
        } else if var environmentReader = value as? EnvironmentReader {
          environmentReader.setContent(from: viewInputs.environment.environment)
          value = environmentReader
        }
        property.set(value: value, on: &view)
      }
      return state
    }

    /// Flip this node with its `alternate` to reflect changes from the reconciler.
    func flip() {
      let child = child
      self.child = alternate?.child
      alternate?.child = child
//      if self.parent?.child === self {
//        self.parent?.child = alternate
//        self.parent?.alternate?.child = self
//      } else {
//        var node = self.parent?.child
//        while node != nil && node?.sibling !== self {
//          node = node?.sibling
//        }
//        node?.alternate?.sibling = self
//        node?.sibling = alternate
//      }
//      let alternateElement = alternate?.element
//      let alternateElementParent = alternate?.elementParent
//      let alternateParent = alternate?.parent
//      let alternateSibling = alternate?.sibling
//      alternate?.element = self.element
//      alternate?.elementParent = self.elementParent
//      alternate?.parent = self.parent
//      alternate?.sibling = self.sibling
//      self.element = alternateElement
//      self.elementParent = alternateElementParent
//      self.parent = alternateParent
//      self.sibling = alternateSibling
    }

    func update<V: View>(
      with view: inout V,
      childIndex: Int
    ) -> Renderer.ElementType.Data? {
      typeInfo = TokamakCore.typeInfo(of: V.self)

      let viewInputs = ViewInputs<V>(
        view: view,
        proposedSize: parent?.outputs.layoutComputer?.proposeSize(for: view, at: childIndex),
        environment: parent?.outputs.environment ?? .init(.init())
      )
      state = bindProperties(to: &view, typeInfo, viewInputs)
      self.view = view
      outputs = V._makeView(viewInputs)
      visitView = { [weak self] in
        guard let self = self else { return }
        // swiftlint:disable:next force_cast
        $0.visit(self.view as! V)
      }

      if Renderer.isPrimitive(view) {
        return .init(from: view)
      } else {
        return nil
      }
    }

    public var debugDescription: String {
      flush()
    }

    private func flush(level: Int = 0) -> String {
//      var result = ""
//      walk(self) { node in
//        result += "\n\(node.typeInfo?.type ?? Any.self)\(node.element != nil ? "(\(node.element!))" : "")"
//        return true
//      }
//      return result
//      return "\(typeInfo?.type ?? Any.self)\(element != nil ? "(\(element!))" : "")"
      let spaces = String(repeating: " ", count: level)
      return """
      \(spaces)\(String(describing: typeInfo?.type ?? Any.self)
        .split(separator: "<")[0])\(element != nil ? "(\(element!))" : "") {
      \(child?.flush(level: level + 2) ?? "")
      \(spaces)}
      \(sibling?.flush(level: level) ?? "")
      """
    }
  }
}

public final class Reconciler<Renderer: GraphRenderer> {
  @_spi(TokamakCore) public var current: ViewNode!
  private var alternate: ViewNode!
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
    // Copy this tree into the alternate so we have two identical trees as a starting point.
//    self.reconcile(from: current)
  }

  /// Convert the first level of children of a `View` into a linked list of `ViewNode`s.
  struct TreeReducer: ViewReducer {
    final class Result {
      // For references
      let viewNode: ViewNode?
      let visitChildren: (TreeReducer.Visitor) -> ()
      unowned var parent: Result?
      var child: Result?
      var sibling: Result?
      var newData: Renderer.ElementType.Data?

      // For reducing
      var childrenCount: Int = 0
      var lastSibling: Result?
      var nextExisting: ViewNode?
      var nextExistingAlternate: ViewNode?

      init(
        viewNode: ViewNode?,
        visitChildren: @escaping (TreeReducer.Visitor) -> (),
        parent: Result?,
        child: ViewNode?,
        alternateChild: ViewNode?,
        newData: Renderer.ElementType.Data? = nil
      ) {
        self.viewNode = viewNode
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
          viewNode: existing,
          visitChildren: nextView._visitChildren,
          parent: partialResult,
          child: existing.child,
          alternateChild: existing.alternate?.child,
          newData: newData
        )
        partialResult.nextExisting = existing.sibling
      } else {
        let viewNode = ViewNode(
          &nextView,
          element: partialResult.nextExistingAlternate?.element,
          parent: partialResult.viewNode,
          elementParent: partialResult.viewNode?.element != nil
            ? partialResult.viewNode
            : partialResult.viewNode?.elementParent,
          childIndex: partialResult.childrenCount,
          reconciler: partialResult.viewNode?.reconciler
        )
        if let alternate = partialResult.nextExistingAlternate {
          viewNode.alternate = alternate
          partialResult.nextExistingAlternate = alternate.sibling
        }
        resultChild = Result(
          viewNode: viewNode,
          visitChildren: nextView._visitChildren,
          parent: partialResult,
          child: nil,
          alternateChild: viewNode.alternate?.child
        )
      }
      partialResult.childrenCount += 1
      // Get the last child element we've processed, and add the new child as its sibling.
      if let lastSibling = partialResult.lastSibling {
        lastSibling.viewNode?.sibling = resultChild.viewNode
        lastSibling.sibling = resultChild
      } else {
        // Otherwise setup the first child
        partialResult.viewNode?.child = resultChild.viewNode
        partialResult.child = resultChild
      }
      partialResult.lastSibling = resultChild
    }
  }

  final class ReconcilerVisitor: ViewVisitor {
    unowned let reconciler: Reconciler<Renderer>
    /// The current, mounted `ViewNode`.
    var currentRoot: ViewNode
    var mutations = [Mutation<Renderer>]()

    init(root: ViewNode, reconciler: Reconciler<Renderer>) {
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
      let alternateRoot: ViewNode?
      if let alternate = currentRoot.alternate {
        alternateRoot = alternate
      } else {
        alternateRoot = currentRoot.createAndBindAlternate?()
      }
      let rootResult = TreeReducer.Result(
        viewNode: alternateRoot, // The alternate is the WIP node.
        visitChildren: view._visitChildren,
        parent: nil,
        child: alternateRoot?.child,
        alternateChild: currentRoot.child
      )
      var node = rootResult
      var elementIndices = [ObjectIdentifier: Int]()

      func reconcile(_ node: TreeReducer.Result) {
        // Compare `node` and its alternate.
        if let element = node.viewNode?.element,
           let parent = node.viewNode?.elementParent?.element
        {
          let key = ObjectIdentifier(parent)
          let index = elementIndices[key, default: 0]
          if node.viewNode?.alternate == nil { // This didn't exist before (no alternate)
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
        if node.viewNode?.alternate == nil {
          node.viewNode?.createAndBindAlternate?()
        }

        // Walk into the child
        if let child = reducer.result.child {
          node = child
          continue
        } else if let alternateChild = node.viewNode?.alternate?.child {
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
          node.viewNode?.child = nil // Make sure we clear the child if there was none
        }

        // When we walk back to the root, exit
        if node === rootResult {
          return
        }
        // Walk back up until we find a sibling
        while node.sibling == nil {
          var alternateSibling = node.viewNode?.alternate?.sibling
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

  func reconcile(from root: ViewNode) {
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

public extension GraphRenderer {
  @discardableResult
  func render<V: View>(_ view: V) -> Reconciler<Self> {
    .init(self, view)
  }
}
