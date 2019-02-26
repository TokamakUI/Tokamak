//
//  MountedCompositeComponent.swift
//  Tokamak
//
//  Created by Max Desiatov on 03/12/2018.
//

import Dispatch

final class MountedCompositeComponent<R: Renderer>: MountedComponent<R>,
  HookedComponent, Hashable {
  static func ==(lhs: MountedCompositeComponent<R>,
                 rhs: MountedCompositeComponent<R>) -> Bool {
    return lhs === rhs
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }

  private var mountedChildren = [MountedComponent<R>]()
  private let parentTarget: R.TargetType
  let type: AnyCompositeComponent.Type

  // HookedComponent implementation

  /// There's no easy way to downcast elements of `[Any]` to `T`
  /// and apply `inout` updater without creating copies, working around
  /// that with pointers.
  var state = [UnsafeMutableRawPointer]()
  var effects = [(observed: AnyEquatable?, Effect)]()
  var effectFinalizers = [Finalizer]()
  var refs = [AnyObject]()

  init(_ node: AnyNode,
       _ type: AnyCompositeComponent.Type,
       _ parentTarget: R.TargetType) {
    self.type = type
    self.parentTarget = parentTarget

    super.init(node)
  }

  deinit {
    for s in state {
      s.deallocate()
    }
  }

  override func mount(with reconciler: StackReconciler<R>) {
    let renderedNode = reconciler.render(component: self)

    let child: MountedComponent<R> =
      renderedNode.makeMountedComponent(parentTarget)
    mountedChildren = [child]
    child.mount(with: reconciler)
  }

  override func unmount(with reconciler: StackReconciler<R>) {
    mountedChildren.forEach { $0.unmount(with: reconciler) }

    DispatchQueue.main.async {
      for f in self.effectFinalizers {
        f?()
      }
    }
  }

  override func update(with reconciler: StackReconciler<R>) {
    // FIXME: for now without fragments mounted composite components have only
    // a single element in `mountedChildren`, but this will change when
    // fragments are implemented and this switch should be rewritten to compare
    // all elements in `mountedChildren`
    switch (mountedChildren.last, reconciler.render(component: self)) {
    // no mounted children, but children available now
    case let (nil, renderedNode):
      let child: MountedComponent<R> =
        renderedNode.makeMountedComponent(parentTarget)
      mountedChildren = [child]
      child.mount(with: reconciler)

    // some mounted children
    case let (wrapper?, renderedNode):
      // new node is the same type as existing child, checking props/children
      if wrapper.node.type == renderedNode.type,
        wrapper.node.props != renderedNode.props ||
        wrapper.node.children != renderedNode.children {
        wrapper.node = renderedNode
        wrapper.update(with: reconciler)
      } else
      // new node is of different type, complete rerender, i.e. unmount old
      // wrapper, then mount a new one with new node
      if wrapper.node.type != renderedNode.type {
        wrapper.unmount(with: reconciler)

        let child: MountedComponent<R> =
          renderedNode.makeMountedComponent(parentTarget)
        mountedChildren = [child]
        child.mount(with: reconciler)
      }
    }
  }
}
