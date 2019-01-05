//
//  MountedCompositeComponent.swift
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

final class MountedCompositeComponent<R: Renderer>: MountedComponent<R>,
  Hashable {
  static func ==(lhs: MountedCompositeComponent<R>,
                 rhs: MountedCompositeComponent<R>) -> Bool {
    return lhs === rhs
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }

  private var mountedChildren = [MountedComponent<R>]()
  private let type: AnyCompositeComponent.Type
  private let parentTarget: R.Target
  var state = [String: Any]()

  init(_ node: AnyNode,
       _ type: AnyCompositeComponent.Type,
       _ parent: MountedComponent<R>?,
       _ parentTarget: R.Target) {
    self.type = type
    self.parentTarget = parentTarget

    super.init(node, parent)
  }

  override func mount(with reconciler: StackReconciler<R>) {
    let renderedNode = render(with: reconciler)

    let child: MountedComponent<R> =
      renderedNode.makeMountedComponent(self, parentTarget)
    mountedChildren = [child]
    child.mount(with: reconciler)
  }

  override func unmount(with reconciler: StackReconciler<R>) {
    mountedChildren.forEach { $0.unmount(with: reconciler) }
    // FIXME: Should call `hooks.effect` finalizers here after `hooks.effect`
    // is implemented
  }

  override func update(with reconciler: StackReconciler<R>) {
    // FIXME: for now without fragments mounted composite components have only
    // a single element in `mountedChildren`, but this will change when
    // fragments are implemented and this switch should be rewritten to compare
    // all elements in `mountedChildren`
    switch (mountedChildren.last, render(with: reconciler)) {
    // no mounted children, but children available now
    case let (nil, renderedNode):
      let child: MountedComponent<R> =
        renderedNode.makeMountedComponent(self, parentTarget)
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

        let child: MountedComponent<R> =
          renderedNode.makeMountedComponent(self, parentTarget)
        mountedChildren = [child]
        child.mount(with: reconciler)
      }
    }
  }

  func render(with reconciler: StackReconciler<R>) -> AnyNode {
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
