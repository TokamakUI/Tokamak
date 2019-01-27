//
//  MountedHostComponent.swift
//  Gluon
//
//  Created by Max Desiatov on 03/12/2018.
//

/* A representation of a `HostComponent` stored in the tree of mounted
 components by `StackReconciler`.
 */
public final class MountedHostComponent<R: Renderer>: MountedComponent<R> {
  private var managedChildren = [Weak<R.Target>: MountedComponent<R>]()
  private var mountedChildren = [MountedComponent<R>]()
  private let parentTarget: R.Target
  private var target: R.Target?

  public let type: AnyHostComponent.Type

  init(_ node: AnyNode,
       _ type: AnyHostComponent.Type,
       _ parent: MountedComponent<R>?,
       _ parentTarget: R.Target) {
    self.type = type
    self.parentTarget = parentTarget

    super.init(node, parent)
  }

  override func mount(with reconciler: StackReconciler<R>) {
    guard
      let target = reconciler.renderer?.mountTarget(to: parentTarget,
                                                    parentNode: parent?.node,
                                                    with: self)
    else { return }

    self.target = target

    switch node.children.value {
    case let nodes as [AnyNode]:
      mountedChildren = nodes.map { $0.makeMountedComponent(self, target) }
      mountedChildren.forEach { $0.mount(with: reconciler) }

    case let node as AnyNode:
      let child: MountedComponent<R> = node.makeMountedComponent(self, target)
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

    reconciler.renderer?.unmount(target: target, with: self)
  }

  override func update(with reconciler: StackReconciler<R>) {
    guard let target = target else { return }

    reconciler.renderer?.update(target: target,
                                with: self)

    switch node.children.value {
    case var nodes as [AnyNode]:
      switch (mountedChildren.isEmpty, nodes.isEmpty) {
      // existing children, new children array is empty, unmount all existing
      case (false, true):
        mountedChildren.forEach { $0.unmount(with: reconciler) }
        mountedChildren = []

      // no existing children, mount all new
      case (true, false):
        mountedChildren = nodes.map { $0.makeMountedComponent(self, target) }
        mountedChildren.forEach { $0.mount(with: reconciler) }

      // both arrays have items, reconcile by types and keys
      case (false, false):
        var newChildren = [MountedComponent<R>]()

        // iterate through every `mountedChildren` element and compare with
        // a corresponding `nodes` element, remount if type differs, otherwise
        // run simple update
        while let child = mountedChildren.first, let node = nodes.first {
          let newChild: MountedComponent<R>
          if node.type == mountedChildren[0].node.type {
            // not sure if comparison of `props` between `child.node` and
            // `node` are more computationally expensive than plainly
            // updating props on a target. `children` comparison between
            // `child.node` and `node` runs implicitly within this loop.
            // From functionality perspective this should work and we need
            // benchmarks before this can be optimised.
            child.node = node
            child.update(with: reconciler)
            newChild = child
          } else {
            child.unmount(with: reconciler)
            newChild = node.makeMountedComponent(self, target)
            newChild.mount(with: reconciler)
          }
          newChildren.append(newChild)
          mountedChildren.removeFirst()
          nodes.removeFirst()
        }

        // more mounted components left than nodes were to be rendered:
        // unmount remaining `mountedChildren`
        if !mountedChildren.isEmpty {
          for child in mountedChildren {
            child.unmount(with: reconciler)
          }
        } else {
          // more nodes left than children were mounted,
          // mount remaining nodes
          for node in nodes {
            let newChild = node.makeMountedComponent(self, target)
            newChild.mount(with: reconciler)
            newChildren.append(newChild)
          }
        }

        mountedChildren = newChildren

      // both arrays are empty, nothing to reconcile
      case (true, true):
        ()
      }

    case let node as AnyNode:
      if let child = mountedChildren.first {
        child.node = node
        child.update(with: reconciler)
      } else {
        let child: MountedComponent<R> = node.makeMountedComponent(self, target)
        child.mount(with: reconciler)
      }

    // child type that can't be rendered, but still makes sense as a child
    // (e.g. `String`)
    default:
      ()
    }
  }
}
