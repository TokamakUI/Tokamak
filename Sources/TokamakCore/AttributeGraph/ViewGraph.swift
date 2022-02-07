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
  var defaultEnvironment: EnvironmentValues { get }
}

public extension GraphRenderer {
  var defaultEnvironment: EnvironmentValues { .init() }
}

public enum RenderableMutation<Renderer: GraphRenderer> {
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
  case update(previous: Renderer.ElementType, newElement: Renderer.ElementType)
}

@_spi(TokamakCore) public extension Reconciler {
  final class ViewNode: CustomDebugStringConvertible {
    weak var reconciler: Reconciler<Renderer>?

    var view: Any!
    var outputs: ViewOutputs!
    var visitView: ((ViewVisitor) -> ())!
    var id: Identity?
    var element: Renderer.ElementType?
    var children: [Reconciler<Renderer>.ViewNode]
    unowned var parent: Reconciler<Renderer>.ViewNode?
    var parentElement: Renderer.ElementType?
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
      element: ((V) -> Renderer.ElementType?)?,
      parent: Reconciler<Renderer>.ViewNode?,
      parentElement: Renderer.ElementType?,
      childIndex: Int,
      reconciler: Reconciler<Renderer>?
    ) {
      self.reconciler = reconciler
      children = []
      self.parent = parent
      self.parentElement = parentElement
      typeInfo = TokamakCore.typeInfo(of: V.self)

      let viewInputs = ViewInputs<V>(
        view: view,
        proposedSize: parent?.outputs.layoutComputer?.proposeSize(for: view, at: childIndex),
        environment: parent?.outputs.environment ?? .init()
      )
      state = bindProperties(to: &view, typeInfo, viewInputs)
      self.view = view
      outputs = V._makeView(viewInputs)
      visitView = { [weak self] in
        guard let self = self else { return }
        // swiftlint:disable:next force_cast
        $0.visit(self.view as! V)
      }

      self.element = element?(view)
    }

    init(
      bound view: Any,
      outputs: ViewOutputs,
      typeInfo: TypeInfo?,
      visitView: @escaping (ViewVisitor) -> (),
      element: Renderer.ElementType?,
      parent: Reconciler<Renderer>.ViewNode?,
      parentElement: Renderer.ElementType?,
      reconciler: Reconciler<Renderer>?
    ) {
      self.view = view
      self.reconciler = reconciler
      self.element = element
      children = []
      self.parent = parent
      self.parentElement = parentElement
      self.typeInfo = typeInfo
      self.visitView = visitView
      self.outputs = outputs
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
          })
          state[property] = box
          storage.getter = { box.value }
          storage.setter = { box.setValue($0, with: $1) }
          value = storage
        } else if var environmentReader = value as? EnvironmentReader {
          environmentReader.setContent(from: viewInputs.environment)
          value = environmentReader
        }
        property.set(value: value, on: &view)
      }
      return state
    }

    func clone() -> Reconciler<Renderer>.ViewNode {
      .init(
        bound: view!,
        outputs: outputs,
        typeInfo: typeInfo,
        visitView: visitView,
        element: nil,
        parent: nil,
        parentElement: nil,
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
    visitor.visit(view.environmentValues(renderer.defaultEnvironment))
    tree = visitor.root
    var mutations = [RenderableMutation<Renderer>]()
    for mutation in visitor.mutations {
      switch mutation {
      case let .insert(viewNode, _, index):
        guard let element = viewNode.element else { continue }
        mutations.append(.insert(
          element: element,
          parent: viewNode.parentElement ?? renderer.rootElement,
          index: index
        ))
      default: continue
      }
    }
    renderer.commit(mutations)
  }

  enum Mutation {
    case insert(ViewNode, parent: ViewNode?, index: Int)
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
      root = .init(
        &view,
        element: nil,
        parent: nil,
        parentElement: reconciler.renderer.rootElement,
        childIndex: 0,
        reconciler: reconciler
      )
      mutations = [.insert(root, parent: nil, index: 0)]
      print(root)
    }

    func visit<V>(_ view: V) where V: View {
      root.view = view
      // Create a stack of nodes and the accessor for their children.
      var accessors: [TreeReducer.Result.Child] = [.init(
        viewNode: root,
        parentElement: root.element ?? root.parentElement,
        visitChildren: { $0.visit(view) }
      )]
      while true {
        guard let next = accessors.popLast() else { return } // Pop from the stack
        // Visit each child, collapsing the result into an array of (ViewNode, Accessor)
        let reducer = TreeReducer.Visitor()
        reducer.result.parent = next.viewNode
        reducer.result.parentElement = next.parentElement
        next.visitChildren(reducer)
        for (index, child) in reducer.result.children.enumerated() {
          child.viewNode.reconciler = reconciler
          child.viewNode.id = .structural(index: index)
          next.viewNode.children.append(child.viewNode)
          mutations.append(.insert(child.viewNode, parent: next.viewNode, index: index))
        }
        accessors.append(contentsOf: reducer.result.children)
      }
    }
  }

  struct TreeReducer: ViewReducer {
    struct Data {
      var parent: ViewNode?
      /// The element to mount this, and its children, on.
      var parentElement: Renderer.ElementType?
      /// The collapsed children.
      var children: [Child]

      struct Child {
        let viewNode: ViewNode
        /// The element to use for this children of this child. Either its own element, or its parent if it has no element.
        let parentElement: Renderer.ElementType?
        let visitChildren: (TreeReducer.Visitor) -> ()
      }
    }

    typealias Result = Data
    static var initialResult: Result { .init(parent: nil, parentElement: nil, children: []) }

    static func reduce<V>(partialResult: Result, nextView: V) -> Result where V: View {
      var nextView = nextView
      let viewNode = ViewNode(
        &nextView,
        element: { view in Renderer.isPrimitive(view) ? Renderer.ElementType(from: view) : nil },
        parent: partialResult.parent,
        parentElement: partialResult.parentElement,
        childIndex: partialResult.children.count,
        // The index is the same as the number of previous children.
        reconciler: nil
      )
      return .init(
        parent: partialResult.parent,
        parentElement: partialResult.parentElement,
        children: partialResult.children + [
          .init(
            viewNode: viewNode,
            parentElement: viewNode.element ?? partialResult.parentElement,
            visitChildren: nextView._visitChildren
          ),
        ]
      )
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
      var accessorStack: [TreeReducer.Result.Child] =
        [.init(
          viewNode: current.clone(),
          parentElement: current.element ?? current.parentElement,
          visitChildren: { view._visitChildren($0) }
        )]
      while true {
        guard let nextNode = nodeStack.popLast(),
              let nextAccessor = accessorStack.popLast()
        else { return } // Pop from the stacks
        // Visit each child, collapsing the result into an array of (ViewNode, Accessor)
        let reducer = TreeReducer.Visitor()
        reducer.result.parent = nextAccessor.viewNode
        reducer.result.parentElement = nextAccessor.parentElement
        nextAccessor.visitChildren(reducer)
        for (index, child) in reducer.result.children.enumerated() {
          child.viewNode.reconciler = current.reconciler
          child.viewNode.id = .structural(index: index)
          nextAccessor.viewNode.children.append(child.viewNode)
          if !nextNode.children.indices.contains(index) {
            mutations.append(.insert(child.viewNode, parent: nextNode, index: index))
          } else {
            let previousChild = nextNode.children[index]
            if child.viewNode.typeInfo?.type != previousChild.typeInfo?.type {
              mutations
                .append(.replace(
                  parent: nextNode,
                  previous: previousChild,
                  current: child.viewNode
                ))
            } else if let newElement = child.viewNode.element,
                      newElement != previousChild.element
            {
              mutations.append(.update(previousChild, newElement: newElement))
            }
          }
        }
        for removed in nextNode.children.dropFirst(reducer.result.children.count) {
          mutations.append(.remove(removed, parent: nextNode))
        }
        accessorStack.append(contentsOf: reducer.result.children)
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
      case let .insert(viewNode, parent, index):
        parent?.children.insert(viewNode, at: index)
        guard let element = viewNode.element else { continue }
        renderableMutations
          .append(.insert(
            element: element,
            parent: viewNode.parentElement ?? renderer.rootElement,
            index: index
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
