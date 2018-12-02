//
//  MountedComponent.swift
//  Gluon
//
//  Created by Max Desiatov on 28/11/2018.
//


// TODO: this won't work in multi-threaded scenarios
private var _hooks = Hooks()

extension CompositeComponent {
  public static var hooks: Hooks {
    return _hooks
  }
}

protocol ComponentWrapper: class {
  var node: Node { get set }

  func mount(with reconciler: StackReconciler)

  func unmount(with reconciler: StackReconciler)

  func update(with reconciler: StackReconciler)
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
      if wrapper.node.type == renderedNode.type &&
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

final class HostComponentWrapper: ComponentWrapper {
  var node: Node
  fileprivate var mountedChildren = [ComponentWrapper]()
  private let type: AnyHostComponent.Type
  private let parentTarget: Any
  private var target: Any?

  init(_ node: Node, _ type: AnyHostComponent.Type, _ parentTarget: Any) {
    self.type = type
    self.node = node
    self.parentTarget = parentTarget
  }

  func mount(with reconciler: StackReconciler) {
    guard let target = reconciler.renderer?.mountTarget(to: parentTarget,
                                                        with: type,
                                                        props: node.props,
                                                        children: node.children)
    else { return }

    self.target = target

    switch node.children.value {
    case let nodes as [Node]:
      mountedChildren = nodes.map { $0.makeComponentWrapper(target) }
      mountedChildren.forEach { $0.mount(with: reconciler) }

    case let node as Node:
      let child = node.makeComponentWrapper(target)
      mountedChildren = [child]
      child.mount(with: reconciler)

    default:
      // child type that can't be rendered, but still makes sense
      // (e.g. `String`)
      ()
    }
  }

  func unmount(with reconciler: StackReconciler) {
    guard let target = target else { return }

    reconciler.renderer?.unmount(target: target, with: type)
  }

  func update(with reconciler: StackReconciler) {
    guard let target = target else { return }

    reconciler.renderer?.update(target: target,
                                with: type,
                                props: node.props,
                                children: node.children)

    switch node.children.value {
    case var nodes as [Node]:
      switch (mountedChildren.isEmpty, nodes.isEmpty) {
      // existing children, new children array is empty, unmount all existing
      case (false, true):
        mountedChildren.forEach { $0.unmount(with: reconciler) }
        mountedChildren = []

      // no existing children, mount all new
      case (true, false):
        mountedChildren = nodes.map { $0.makeComponentWrapper(target) }
        mountedChildren.forEach { $0.mount(with: reconciler) }

      // both arrays have items, reconcile by types and keys
      case (false, false):
        var newChildren = [ComponentWrapper]()

        while let child = mountedChildren.first, let node = nodes.first {
          if node.key != nil &&
          node.type == mountedChildren[0].node.type &&
          node.key == child.node.key {
            child.node = node
            child.update(with: reconciler)
            newChildren.append(child)
            mountedChildren.removeFirst()
          } else {
            let newChild = node.makeComponentWrapper(reconciler)
            newChild.mount(with: reconciler)
            newChildren.append(newChild)
          }
          nodes.removeFirst()
        }

        mountedChildren = newChildren

      // both arrays are empty, nothing to reconcile
      case (true, true):
        ()
      }

    case let node as Node:
      if let child = mountedChildren.first {
        child.node = node
        child.update(with: reconciler)
      } else {
        let child = node.makeComponentWrapper(target)
        child.mount(with: reconciler)
      }

    // child type that can't be rendered, but still makes sense as a child
    // (e.g. `String`)
    default:
      ()
    }
  }
}
