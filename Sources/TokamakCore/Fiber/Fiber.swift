//
//  File.swift
//
//
//  Created by Carson Katri on 2/15/22.
//

@_spi(TokamakCore) public extension FiberReconciler {
  final class Fiber: CustomDebugStringConvertible {
    weak var reconciler: FiberReconciler<Renderer>?

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
    var child: Fiber?
    /// This node's right sibling.
    var sibling: Fiber?
    /// An unowned reference to the parent node.
    unowned var parent: Fiber?
    /// The nearest parent that can be mounted on.
    unowned var elementParent: Fiber?
    /// The cached type information for the underlying `View`.
    var typeInfo: TypeInfo?
    /// Boxes that store `State` data.
    var state: [PropertyInfo: MutableStorage]!

    /// The WIP node if this is current, or the current node if this is WIP.
    weak var alternate: Fiber?

    var createAndBindAlternate: (() -> Fiber)?

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
      parent: Fiber?,
      elementParent: Fiber?,
      childIndex: Int,
      reconciler: FiberReconciler<Renderer>?
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
        let alternate = Fiber(
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
      alternate: Fiber,
      outputs: ViewOutputs,
      typeInfo: TypeInfo?,
      element: Renderer.ElementType?,
      parent: FiberReconciler<Renderer>.Fiber?,
      elementParent: Fiber?,
      reconciler: FiberReconciler<Renderer>?
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
