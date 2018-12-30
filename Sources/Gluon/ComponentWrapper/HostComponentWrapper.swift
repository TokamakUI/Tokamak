//
//  HostComponentWrapper.swift
//  Gluon
//
//  Created by Max Desiatov on 03/12/2018.
//

final class HostComponentWrapper<R: Renderer>: ComponentWrapper<R> {
  private var mountedChildren = [ComponentWrapper<R>]()
  private let type: AnyHostComponent.Type
  private let parentTarget: R.Target
  private var target: R.Target?

  init(_ node: Node, _ type: AnyHostComponent.Type, _ parentTarget: R.Target) {
    self.type = type
    self.parentTarget = parentTarget

    super.init(node)
  }

  override func mount(with reconciler: StackReconciler<R>) {
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
      let child: ComponentWrapper<R> = node.makeComponentWrapper(target)
      mountedChildren = [child]
      child.mount(with: reconciler)

    default:
      // child type that can't be rendered, but still makes sense
      // (e.g. `String`)
      ()
    }
  }

  override func unmount(with reconciler: StackReconciler<R>) {
    guard let target = target else { return }

    reconciler.renderer?.unmount(target: target, with: type)
  }

  override func update(with reconciler: StackReconciler<R>) {
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
        var newChildren = [ComponentWrapper<R>]()

        while let child = mountedChildren.first, let node = nodes.first {
          let newChild: ComponentWrapper<R>
          if node.type == mountedChildren[0].node.type {
            child.node = node
            child.update(with: reconciler)
            newChild = child
          } else {
            child.unmount(with: reconciler)
            newChild = node.makeComponentWrapper(target)
            newChild.mount(with: reconciler)
          }
          newChildren.append(newChild)
          mountedChildren.removeFirst()
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
        let child: ComponentWrapper<R> = node.makeComponentWrapper(target)
        child.mount(with: reconciler)
      }

    // child type that can't be rendered, but still makes sense as a child
    // (e.g. `String`)
    default:
      ()
    }
  }
}
