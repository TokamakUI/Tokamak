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

final class CompositeComponentWrapper: ComponentWrapper {
  var node: Node
  private var mountedChildren = [ComponentWrapper]()
  private let type: AnyCompositeComponent.Type
  private let parentTarget: Any
  var state = [String: Any]()

  init(_ node: Node, _ type: AnyCompositeComponent.Type, _ parentTarget: Any) {
    self.node = node
    self.type = type
    self.parentTarget = parentTarget
  }

  func mount(with reconciler: StackReconciler) {
    let renderedNode = render(with: reconciler)

    let child = renderedNode.makeComponentWrapper(parentTarget)
    mountedChildren = [child]
    child.mount(with: reconciler)
  }

  func unmount(with reconciler: StackReconciler) {
    mountedChildren.forEach { $0.unmount(with: reconciler) }
    // FIXME: Should call `hooks.effect` finalizers here after `hooks.effect`
    // is implemented
  }

  func update(with reconciler: StackReconciler) {
    switch (mountedChildren.last, render(with: reconciler)) {
    // no mounted children, but children available now
    case let (nil, renderedNode):
      let child = renderedNode.makeComponentWrapper(parentTarget)
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

        let child = renderedNode.makeComponentWrapper(parentTarget)
        mountedChildren = [child]
        child.mount(with: reconciler)
      }
    }
  }

  func render(with reconciler: StackReconciler) -> Node {
    _hooks.currentReconciler = reconciler
    _hooks.currentComponent = self

    let result = type.render(props: node.props, children: node.children)

    _hooks.currentComponent = nil
    _hooks.currentReconciler = nil

    return result
  }
}
