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
  static func reduce<V: View>(partialResult: Result, nextView: V) -> Result
}

final class ReducerVisitor<R: ViewReducer>: ViewVisitor {
  var result: R.Result

  init(initialResult: R.Result) {
    result = initialResult
  }

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
    var children: [ViewNode]
    unowned var parent: ViewNode?
    var elementParent: ViewNode?
    var typeInfo: TypeInfo?
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
      parent: ViewNode?,
      elementParent: ViewNode?,
      childIndex: Int,
      reconciler: Reconciler<Renderer>?
    ) {
      self.reconciler = reconciler
      children = []
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

      self.element = element?(view)
    }

    init(
      bound view: Any,
      outputs: ViewOutputs,
      typeInfo: TypeInfo?,
      visitView: @escaping (ViewVisitor) -> (),
      element: Renderer.ElementType?,
      parent: Reconciler<Renderer>.ViewNode?,
      elementParent: ViewNode?,
      reconciler: Reconciler<Renderer>?
    ) {
      self.view = view
      self.reconciler = reconciler
      self.element = element
      children = []
      self.parent = parent
      self.elementParent = elementParent
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
            guard let self = self,
                  let wip = self.reconciler?.reconcile(from: self) else { return }
            self.apply(wip)
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

    func clone() -> ViewNode {
      .init(
        bound: view!,
        outputs: outputs,
        typeInfo: typeInfo,
        visitView: visitView,
        element: element,
        parent: parent,
        elementParent: elementParent,
        reconciler: reconciler
      )
    }

    private func apply(_ wip: ViewNode) {
      view = wip.view
      outputs = wip.outputs
      visitView = wip.visitView
      id = wip.id
      element = wip.element
      children = wip.children
      parent = wip.parent
      elementParent = wip.elementParent
      typeInfo = wip.typeInfo
      state = wip.state
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

  func child(at index: Int) -> Reconciler<Renderer>.ViewNode? {
    guard children.indices.contains(index) else { return nil }
    return children[index]
  }
}

public final class Reconciler<Renderer: GraphRenderer> {
  @_spi(TokamakCore) public var tree: ViewNode!
  public let renderer: Renderer

  public init<V: View>(_ renderer: Renderer, _ view: V) {
    self.renderer = renderer
    var view = view.environmentValues(renderer.defaultEnvironment)
    tree = .init(
      &view,
      element: { _ in renderer.rootElement },
      parent: nil,
      elementParent: nil,
      childIndex: 0,
      reconciler: self
    )
    tree = reconcile(from: tree)
  }

  struct TreeReducer: ViewReducer {
    struct Data {
      let reconciler: Reconciler?
      var parent: ViewNode?
      /// The element to mount this, and its children, on.
      var elementParent: ViewNode?
      /// The collapsed children.
      var children: [Child]

      struct Child {
        let viewNode: ViewNode
        /// The element to use for this children of this child (aka, the grandchildren). Either its own element, or its parent if it has no element.
        let elementParent: ViewNode?
        let visitChildren: (TreeReducer.Visitor) -> ()
      }
    }

    typealias Result = Data

    static func reduce<V>(partialResult: Result, nextView: V) -> Result where V: View {
      var nextView = nextView
      let viewNode = ViewNode(
        &nextView,
        element: { view in Renderer.isPrimitive(view) ? Renderer.ElementType(from: view) : nil },
        parent: partialResult.parent,
        elementParent: partialResult.elementParent,
        childIndex: partialResult.children.count,
        // The index is the same as the number of previous children.
        reconciler: partialResult.reconciler
      )
      return .init(
        reconciler: partialResult.reconciler,
        parent: partialResult.parent,
        elementParent: partialResult.elementParent,
        children: partialResult.children + [
          .init(
            viewNode: viewNode,
            elementParent: viewNode.element != nil ? viewNode : partialResult.elementParent,
            visitChildren: nextView._visitChildren
          ),
        ]
      )
    }
  }

  final class ReconcilerVisitor: ViewVisitor {
    unowned let reconciler: Reconciler<Renderer>
    var currentRoot: ViewNode
    let wipRoot: ViewNode
    var mutations = [Mutation<Renderer>]()

    init(root: ViewNode, reconciler: Reconciler<Renderer>) {
      self.reconciler = reconciler
      currentRoot = root
      wipRoot = root.clone()
    }

    func visit<V>(_ view: V) where V: View {
      /// A stack for walking the current tree of view nodes.
      var currentStack = [currentRoot]
      /// A stack for walking a new tree of view nodes.
      var wipStack = [TreeReducer.Result.Child(
        viewNode: wipRoot,
        elementParent: wipRoot.element != nil ? wipRoot : wipRoot.elementParent,
        visitChildren: { view._visitChildren($0) }
      )]
      /// The number of actual elements added to any given `elementParent`.
      var elementIndices = [ObjectIdentifier: Int]()
      while true {
        if let current = currentStack.popLast() {
          if let wip = wipStack.popLast() {
            if wip.viewNode !== wipRoot {
              wip.viewNode.parent?.children.append(wip.viewNode)
            }
            if wip.viewNode.element != nil,
               let parent = wip.viewNode.elementParent
            {
              let id = ObjectIdentifier(parent)
              elementIndices[id] = elementIndices[id, default: 0] + 1
            }

            // Compute the next WIP children
            let reducer = TreeReducer.Visitor(initialResult: .init(
              reconciler: reconciler,
              parent: wip.viewNode,
              elementParent: wip.elementParent,
              children: []
            ))
            wip.visitChildren(reducer)

            if current.typeInfo?.type != wip.viewNode.typeInfo?.type {
              // The new view is a completely different type than the previous element.
              if let previous = current.element,
                 let replacement = wip.viewNode.element,
                 let parent = wip.viewNode.elementParent?.element
              {
                mutations
                  .append(.replace(parent: parent, previous: previous, replacement: replacement))
              } else {
                // We couldn't replace the root, so remove the top-level children with elements of the original
                var removeStack = [current]
                while true {
                  guard let remove = removeStack.popLast()
                  else { break }
                  if let element = remove.element {
                    // This is a child with an element. Remove it and stop.
                    mutations
                      .append(.remove(element: element, parent: remove.elementParent?.element))
                  } else {
                    // This is a child without an element. Keep walking down until we hit an element.
                    removeStack.append(contentsOf: remove.children.reversed())
                  }
                }
              }
              // Push the children of the replacement too.
              var childStack = reducer.result.children
              while true {
                guard let child = childStack.popLast() else { break }
                child.viewNode.parent?.children.append(child.viewNode)
                if let element = child.viewNode.element,
                   let parent = child.viewNode.elementParent?.element
                {
                  let id = ObjectIdentifier(parent)
                  mutations
                    .append(.insert(
                      element: element,
                      parent: parent,
                      index: elementIndices[id, default: 0]
                    ))
                  elementIndices[id] = elementIndices[id, default: 0] + 1
                }
                let reducer = TreeReducer.Visitor(initialResult: .init(
                  reconciler: reconciler,
                  parent: child.viewNode,
                  elementParent: child.elementParent,
                  children: []
                ))
                child.visitChildren(reducer)
                childStack.append(contentsOf: reducer.result.children.reversed())
              }
              // Push the current element back on the stack, because it may match something upcoming...
//              currentStack.append(current)
              continue // Don't push the current children yet, because we haven't actually matched it yet.
            } else if let previous = current.element,
                      let newElement = wip.viewNode.element,
                      previous != newElement
            {
              mutations.append(.update(previous: previous, newElement: newElement))
            } else {
              // It matches, so keep the previous element in our WIP tree.
              wip.viewNode.element = current.element
            }
            // Reverse it so we always walk down the first child,
            // then back out and into its sibling, and so on.
            wipStack.append(contentsOf: reducer.result.children.reversed())
            currentStack.append(contentsOf: current.children.reversed())
          } else {
            // If a node in the current tree is not in the WIP tree, then we removed it.
            if let element = current.element {
              mutations.append(.remove(element: element, parent: current.elementParent?.element))
            }
            return // And break from the loop.
          }
        } else if let wip = wipStack.popLast() {
          // If a node in the WIP tree is not in the current tree, then we inserted it.
          wip.viewNode.parent?.children.append(wip.viewNode)
          if let element = wip.viewNode.element,
             let parent = wip.viewNode.elementParent?.element
          {
            let id = ObjectIdentifier(parent)
            mutations.append(.insert(
              element: element,
              parent: parent,
              index: elementIndices[id, default: 0]
            ))
            elementIndices[id] = elementIndices[id, default: 0] + 1
          }
          let reducer = TreeReducer.Visitor(initialResult: .init(
            reconciler: reconciler,
            parent: wip.viewNode,
            elementParent: wip.elementParent,
            children: []
          ))
          wip.visitChildren(reducer)
          // Reverse it so we always walk down the first child,
          // then back out and into its sibling, and so on.
          wipStack.append(contentsOf: reducer.result.children.reversed())
        } else {
          // When we run out of nodes in the current tree and the WIP tree, break.
          return
        }
      }
    }
  }

  func reconcile(from root: ViewNode) -> ViewNode {
    let visitor = ReconcilerVisitor(root: root, reconciler: self)
    root.visitView(visitor)
    // Apply mutations to the rendered output.
    renderer.commit(visitor.mutations)
    // Return the new tree
    return visitor.wipRoot
  }
}

public extension GraphRenderer {
  @discardableResult
  func render<V: View>(_ view: V) -> Reconciler<Self> {
    .init(self, view)
  }
}
