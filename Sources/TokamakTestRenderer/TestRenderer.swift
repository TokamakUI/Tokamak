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
    reconciler!.rootTarget
  }

  public init<V: View>(_ node: V) {
    reconciler = StackReconciler(node: node,
                                 target: TestView(EmptyView()),
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
  ) {}

  public func unmount(
    target: TestView,
    from parent: TestView,
    with component: TestRenderer.MountedHost,
    completion: () -> ()
  ) {
    target.removeFromSuperview()
  }
}
