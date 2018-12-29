//
//  CompositeComponentWrapper.swift
//  Gluon
//
//  Created by Max Desiatov on 03/12/2018.
//

// TODO: this won't work with multi-threaded reconcilers/renderers
private var _hooks = Hooks()

extension CompositeComponent {
  public static var hooks: Hooks {
    return _hooks
  }
}

final class CompositeComponentWrapper<R: Renderer>: ComponentWrapper<R>,
Hashable {
  static func ==(lhs: CompositeComponentWrapper<R>,
                 rhs: CompositeComponentWrapper<R>) -> Bool {
    return lhs === rhs
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }

  private var mountedChildren = [ComponentWrapper<R>]()
  private let type: AnyCompositeComponent.Type
  private let parentTarget: R.Target
  var state = [String: Any]()

  init(_ node: Node,
       _ type: AnyCompositeComponent.Type,
       _ parentTarget: R.Target) {
    self.type = type
    self.parentTarget = parentTarget

    super.init(node)
  }

  override func mount(with reconciler: StackReconciler<R>) {
    let renderedNode = render(with: reconciler)

    let child: ComponentWrapper<R> =
      renderedNode.makeComponentWrapper(parentTarget)
    mountedChildren = [child]
    child.mount(with: reconciler)
  }

  override func unmount(with reconciler: StackReconciler<R>) {
    mountedChildren.forEach { $0.unmount(with: reconciler) }
    // FIXME: Should call `hooks.effect` finalizers here after `hooks.effect`
    // is implemented
  }

  override func update(with reconciler: StackReconciler<R>) {
    switch (mountedChildren.last, render(with: reconciler)) {
    // no mounted children, but children available now
    case let (nil, renderedNode):
      let child: ComponentWrapper<R> =
        renderedNode.makeComponentWrapper(parentTarget)
      mountedChildren = [child]
      child.mount(with: reconciler)

    // some mounted children
    case let (wrapper?, renderedNode):
      // new node is the same type as existing child, checking props/children
      if wrapper.node.type == renderedNode.type,
        (wrapper.node.props != renderedNode.props ||
          wrapper.node.children != renderedNode.children) {
        wrapper.node = renderedNode
        wrapper.update(with: reconciler)
      } else
      // new node is of different type, complete rerender, i.e. unmount old
      // wrapper, then mount a new one with new node
      if wrapper.node.type != renderedNode.type {
        wrapper.unmount(with: reconciler)

        let child: ComponentWrapper<R> =
          renderedNode.makeComponentWrapper(parentTarget)
        mountedChildren = [child]
        child.mount(with: reconciler)
      }
    }
  }

  func render(with reconciler: StackReconciler<R>) -> Node {
    _hooks.currentState = { [weak self] in
      self?.state[$0]
    }

    // Avoiding an indirect reference cycle here: this closure can be
    // owned by callbacks owned by node's target, which is strongly referenced
    // by the reconciler.
    _hooks.queueState = { [weak reconciler, weak self] in
      guard let self = self else { return }
      reconciler?.queue(state: $0, for: self, id: $1)
    }

    let result = type.render(props: node.props, children: node.children)

    _hooks.currentState = nil
    _hooks.queueState = nil

    return result
  }
}
