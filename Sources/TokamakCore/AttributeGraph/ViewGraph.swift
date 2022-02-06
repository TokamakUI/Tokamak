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
  static var initialResult: Result { get }
  static func reduce<V: View>(partialResult: Result, nextView: V) -> Result
}

final class ReducerVisitor<R: ViewReducer>: ViewVisitor {
  var result: R.Result = R.initialResult

  func visit<V>(_ view: V) where V: View {
    result = R.reduce(partialResult: result, nextView: view)
  }
}

extension ViewReducer {
  typealias Visitor = ReducerVisitor<Self>
}

/// An output from a `Renderer`.
public protocol Element: AnyObject, Equatable {
  init<V: View>(from primitiveView: V)
}

public protocol GraphRenderer {
  associatedtype ElementType: Element
  static func isPrimitive<V>(_ view: V) -> Bool where V: View
  func commit(_ mutations: [RenderableMutation<Self>])
  var rootElement: ElementType { get }
}

public enum RenderableMutation<Renderer: GraphRenderer> {
  case insert(
    element: Renderer.ElementType,
    parent: Renderer.ElementType,
    sibling: Renderer.ElementType?
  )
  case remove(element: Renderer.ElementType, parent: Renderer.ElementType?)
  case replace(
    parent: Renderer.ElementType,
    previous: Renderer.ElementType,
    replacement: Renderer.ElementType
  )
  case update(previous: Renderer.ElementType, newElement: Renderer.ElementType)
}

@_spi(TokamakCore) public extension Reconciler {
  final class ViewNode: CustomDebugStringConvertible {
    weak var reconciler: Reconciler<Renderer>?

    var view: Any!
    var visitView: ((ViewVisitor) -> ())!
    var id: Identity?
    var element: Renderer.ElementType?
    var children: [Reconciler<Renderer>.ViewNode]
    unowned var parent: Reconciler<Renderer>.ViewNode?
    let typeInfo: TypeInfo?
    var state: [PropertyInfo: MutableStorage]!

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
      parent: Reconciler<Renderer>.ViewNode?,
      reconciler: Reconciler<Renderer>?
    ) {
      self.reconciler = reconciler
      self.element = element
      children = []
      self.parent = parent
      typeInfo = TokamakCore.typeInfo(of: V.self)

      state = bindProperties(to: &view, typeInfo)
      self.view = view
      visitView = { [weak self] in
        guard let self = self else { return }
        // swiftlint:disable:next force_cast
        $0.visit(self.view as! V)
      }
    }

    init(
      bound view: Any,
      typeInfo: TypeInfo?,
      visitView: @escaping (ViewVisitor) -> (),
      element: Renderer.ElementType?,
      parent: Reconciler<Renderer>.ViewNode?,
      reconciler: Reconciler<Renderer>?
    ) {
      self.view = view
      self.reconciler = reconciler
      self.element = element
      children = []
      self.parent = parent
      self.typeInfo = typeInfo
      self.visitView = visitView
    }

    private func bindProperties<V: View>(
      to view: inout V,
      _ typeInfo: TypeInfo?
    ) -> [PropertyInfo: MutableStorage] {
      guard let typeInfo = typeInfo else { return [:] }

      var state: [PropertyInfo: MutableStorage] = [:]
      for property in typeInfo.properties where property.type is DynamicProperty.Type {
        var value = property.get(from: view)
        if var storage = value as? WritableValueStorage {
          let box = MutableStorage(initialValue: storage.anyInitialValue, onSet: { [weak self] in
            guard let self = self else { return }
            self.reconciler?.reconcile(from: self)
          })
          state[property] = box
          storage.getter = { box.value }
          storage.setter = { box.setValue($0, with: $1) }
          value = storage
        }
        property.set(value: value, on: &view)
      }
      return state
    }

    func clone() -> Reconciler<Renderer>.ViewNode {
      .init(
        bound: view!,
        typeInfo: typeInfo,
        visitView: visitView,
        element: nil,
        parent: nil,
        reconciler: reconciler
      )
    }

    public var debugDescription: String {
      flush()
    }

    private func flush(level: Int = 0) -> String {
      let spaces = String(repeating: "  ", count: level)
      let elementDescription: String
      if let element = element {
        elementDescription = """
        (
        \(spaces)  \(String(describing: element))
        \(spaces))
        """
      } else {
        elementDescription = ""
      }
      let childrenDescription: String
      if children.isEmpty {
        childrenDescription = ""
      } else {
        childrenDescription = """
        {
        \(children.map { $0.flush(level: level + 1) }.joined(separator: "\n"))
        \(spaces)}
        """
      }
      return """
      \(spaces)\(String(describing: type(of: view!))
        .split(separator: "<")[0])\(elementDescription) \(childrenDescription)
      """
    }
  }
}

@_spi(TokamakCore) public extension Reconciler.ViewNode {
  func traverse<Result>(_ work: (Reconciler<Renderer>.ViewNode) -> Result?) -> Result? {
    var stack = children
    while true {
      guard let next = stack.popLast() else { return nil }
      if let result = work(next) {
        return result
      }
      stack.insert(contentsOf: next.children, at: 0)
    }
  }

  func findView(id: Reconciler<Renderer>.ViewNode.Identity) -> Reconciler<Renderer>.ViewNode? {
    traverse { node in
      node.id == id ? node : nil
    }
  }
}

public final class Reconciler<Renderer: GraphRenderer> {
  @_spi(TokamakCore) public var tree: ViewNode!
  public let renderer: Renderer

  public init<V: View>(_ renderer: Renderer, _ view: V) {
    self.renderer = renderer
    let visitor = InitialTreeBuilderVisitor(reconciler: self)
    visitor.visit(view)
    tree = visitor.root
    var mutations = [RenderableMutation<Renderer>]()
    for mutation in visitor.mutations {
      switch mutation {
      case let .insert(viewNode, parent, sibling):
        guard let element = viewNode.element else { continue }
        mutations.append(.insert(
          element: element,
          parent: parent?.element ?? renderer.rootElement,
          sibling: sibling?.element
        ))
      default: continue
      }
    }
  }

  enum Mutation {
    case insert(ViewNode, parent: ViewNode?, sibling: ViewNode?)
    case remove(ViewNode, parent: ViewNode)
    case replace(
      parent: ViewNode,
      previous: ViewNode,
      current: ViewNode
    )
    case update(ViewNode, newElement: Renderer.ElementType)
  }

  final class InitialTreeBuilderVisitor: ViewVisitor {
    var root: ViewNode
    var reconciler: Reconciler<Renderer>
    var mutations: [Mutation]

    init(reconciler: Reconciler<Renderer>) {
      self.reconciler = reconciler
      var view = EmptyView()
      root = .init(&view, element: nil, parent: nil, reconciler: reconciler)
      mutations = [.insert(root, parent: nil, sibling: nil)]
    }

    func visit<V>(_ view: V) where V: View {
      root.view = view
      // Create a stack of nodes and the accessor for their children.
      var accessors: [(ViewNode, (TreeReducer.Visitor) -> ())] =
        [(root, { $0.visit(view) })]
      while true {
        guard let next = accessors.popLast() else { return } // Pop from the stack
        // Visit each child, collapsing the result into an array of (ViewNode, Accessor)
        let reducer = TreeReducer.Visitor()
        next.1(reducer)
        var lastSibling: ViewNode?
        for (index, child) in reducer.result.enumerated() {
          child.0.parent = next.0
          child.0.reconciler = reconciler
          child.0.id = .structural(index: index)
          next.0.children.append(child.0)
          mutations.append(.insert(child.0, parent: next.0, sibling: lastSibling))
          lastSibling = child.0
        }
        accessors.append(contentsOf: reducer.result)
      }
    }
  }

  struct TreeReducer: ViewReducer {
    typealias Result = [(ViewNode, visitChildren: (TreeReducer.Visitor) -> ())]
    static var initialResult: Result { [] }

    static func reduce<V>(partialResult: Result, nextView: V) -> Result where V: View {
      var nextView = nextView
      return partialResult + [(ViewNode(
        &nextView,
        element: Renderer.isPrimitive(nextView) ? Renderer.ElementType(from: nextView) : nil,
        parent: nil,
        reconciler: nil
      ), nextView._visitChildren)]
    }
  }

  final class ReconcilerVisitor: ViewVisitor {
    var current: ViewNode
    var mutations = [Mutation]()

    init(current: ViewNode) {
      self.current = current
    }

    func visit<V>(_ view: V) where V: View {
      var nodeStack = [current]
      var accessorStack: [(ViewNode, (TreeReducer.Visitor) -> ())] =
        [(current.clone(), { view._visitChildren($0) })]
      while true {
        guard let nextNode = nodeStack.popLast(),
              let nextAccessor = accessorStack.popLast()
        else { return } // Pop from the stacks
        // Visit each child, collapsing the result into an array of (ViewNode, Accessor)
        let reducer = TreeReducer.Visitor()
        nextAccessor.1(reducer)
        var lastSibling: ViewNode?
        for (index, child) in reducer.result
          .enumerated()
        {
          child.0.parent = nextAccessor.0
          child.0.reconciler = current.reconciler
          child.0.id = .structural(index: index)
          nextAccessor.0.children.append(child.0)
          if !nextNode.children.indices.contains(index) {
            mutations.append(.insert(child.0, parent: nextNode, sibling: lastSibling))
          } else {
            let previousChild = nextNode.children[index]
            if child.0.typeInfo?.type != previousChild.typeInfo?.type {
              mutations
                .append(.replace(parent: nextNode, previous: previousChild, current: child.0))
            } else if let newElement = child.0.element,
                      newElement != previousChild.element
            {
              mutations.append(.update(previousChild, newElement: newElement))
            }
            lastSibling = previousChild
          }
        }
        for removed in nextNode.children.dropFirst(reducer.result.count) {
          mutations.append(.remove(removed, parent: nextNode))
        }
        accessorStack.append(contentsOf: reducer.result)
        nodeStack.append(contentsOf: nextNode.children)
      }
    }
  }

  func reconcile(from current: ViewNode) {
    let visitor = ReconcilerVisitor(current: current)
    current.visitView(visitor)
    // Apply mutations to the tree and the renderer.
    var renderableMutations = [RenderableMutation<Renderer>]()
    for mutation in visitor.mutations {
      switch mutation {
      case let .insert(viewNode, parent, sibling):
        if let sibling = sibling,
           let index = parent?.children.firstIndex(where: { $0 === sibling })
        {
          parent?.children.insert(viewNode, at: index + 1)
        } else {
          parent?.children.insert(viewNode, at: 0)
        }
        guard let element = viewNode.element else { continue }
        renderableMutations
          .append(.insert(
            element: element,
            parent: parent?.element ?? renderer.rootElement,
            sibling: sibling?.element
          ))
      case let .remove(viewNode, parent):
        guard let index = parent.children.firstIndex(where: { $0 === viewNode }) else { continue }
        parent.children.remove(at: index)
        guard let element = viewNode.element else { continue }
        renderableMutations.append(.remove(element: element, parent: parent.element))
      case let .replace(parent, previous, current):
        guard let index = parent.children.firstIndex(where: { $0 === previous }) else { continue }
        parent.children[index] = current
        if let parentElement = parent.element,
           let previousElement = previous.element,
           let currentElement = current.element
        {
          renderableMutations
            .append(.replace(
              parent: parentElement,
              previous: previousElement,
              replacement: currentElement
            ))
        }
      case let .update(viewNode, newElement):
        if let previous = viewNode.element {
          renderableMutations.append(.update(previous: previous, newElement: newElement))
        }
        viewNode.element = newElement
      }
    }
    renderer.commit(renderableMutations)
  }
}

public extension GraphRenderer {
  @discardableResult
  func render<V: View>(_ view: V) -> Reconciler<Self> {
    .init(self, view)
  }
}
