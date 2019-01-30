//
//  TestRenderer.swift
//  GluonTestRenderer
//
//  Created by Max Desiatov on 21/12/2018.
//

import Gluon

public final class TestRenderer: Renderer {
  public private(set) var reconciler: StackReconciler<TestRenderer>?

  public var rootTarget: TestView {
    return reconciler!.rootTarget
  }

  public init(_ node: AnyNode) {
    let root = TestView(View.node())
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
    target.node = component.node
  }

  public func unmount(
    target: TestView,
    with component: TestRenderer.MountedHost
  ) {
    target.removeFromSuperview()
  }
}
