//
//  MountedCompositeComponent.swift
//  Tokamak
//
//  Created by Max Desiatov on 03/12/2018.
//

import Dispatch
import Runtime

final class MountedCompositeComponent<R: Renderer>: MountedComponent<R>,
  HookedComponent, Hashable {
  static func ==(lhs: MountedCompositeComponent<R>,
                 rhs: MountedCompositeComponent<R>) -> Bool {
    lhs === rhs
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }

  private var mountedChildren = [MountedComponent<R>]()
  private let parentTarget: R.TargetType

  // HookedComponent implementation
  var state = [Any]()

  init(_ node: AnyView,
       _ parentTarget: R.TargetType) {
    self.parentTarget = parentTarget

    super.init(node)
  }

  override func mount(with reconciler: StackReconciler<R>) {
    let renderedNode = reconciler.render(component: self)

    let child: MountedComponent<R> = renderedNode.makeMountedComponent(parentTarget)
    mountedChildren = [child]
    child.mount(with: reconciler)
  }

  override func unmount(with reconciler: StackReconciler<R>) {
    mountedChildren.forEach { $0.unmount(with: reconciler) }
  }

  override func update(with reconciler: StackReconciler<R>) {
    // FIXME: for now without fragments (groups?) mounted composite components have only
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
      let renderedNodeType = (renderedNode as? AnyView)?.type ?? type(of: renderedNode)

      // FIXME: no idea if using `mangledName` is reliable, but seems to be the only way to get
      // a name of a type constructor in runtime. Should definitely check if these are different
      // across modules, otherwise can cause problems with views with same names in different
      // modules.

      // new node is the same type as existing child
      // swiftlint:disable:next force_try
      if try! wrapper.node.typeConstructorName == typeInfo(of: renderedNodeType).mangledName {
        wrapper.node = AnyView(renderedNode)
        wrapper.update(with: reconciler)
      } else {
        // new node is of different type, complete rerender, i.e. unmount old
        // wrapper, then mount a new one with new node
        wrapper.unmount(with: reconciler)

        let child: MountedComponent<R> =
          renderedNode.makeMountedComponent(parentTarget)
        mountedChildren = [child]
        child.mount(with: reconciler)
      }
    }
  }
}
