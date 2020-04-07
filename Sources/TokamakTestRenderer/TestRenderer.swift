//
//  TestRenderer.swift
//  TokamakTestRenderer
//
//  Created by Max Desiatov on 21/12/2018.
//

import Tokamak

public final class TestRenderer: Renderer {
  public private(set) var reconciler: StackReconciler<TestRenderer>?

  public var rootTarget: TestView {
    return reconciler!.rootTarget
  }

  public init(_ node: AnyNode) {
    let root = TestView(ViewComponent.node())
    reconciler = StackReconciler(node: node,
                                 target: root,
                                 renderer: self)
  }

  public func mountTarget(
    to parent: TestView,
    with component: TestRenderer.MountedHost
  ) -> TestView? {
    let result = TestView(component.node)
    parent.add(subview: result)

    return result
  }

  public func update(
    target: TestView,
    with component: TestRenderer.MountedHost
  ) {
    guard
      let componentType = component.type as? AnyRefComponent.Type,
      let anyRef = component.node.ref else { return }

    componentType.update(ref: anyRef, with: target)
  }

  public func unmount(
    target: TestView,
    from parent: TestView,
    with component: TestRenderer.MountedHost,
    completion: () -> ()
  ) {
    target.removeFromSuperview()
  }
}
