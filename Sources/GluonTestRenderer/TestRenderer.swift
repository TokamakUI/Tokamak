//
//  TestRenderer.swift
//  GluonTestRenderer
//
//  Created by Max Desiatov on 21/12/2018.
//

import Gluon

public class TestRenderer: Renderer {
  private var reconciler: StackReconciler<TestRenderer>!

  public var rootTarget: TestView {
    return reconciler.rootTarget
  }

  public init(_ node: AnyNode) {
    let root = TestView(View.node())
    reconciler = StackReconciler(node: node,
                                 target: root,
                                 renderer: self)
  }

  public func mountTarget(to parent: TestView,
                          parentNode: AnyNode?,
                          with component: AnyHostComponent.Type,
                          node: AnyNode) -> TestView? {
    let result = TestView(node)
    parent.add(subview: result)

    return result
  }

  public func update(target: TestView,
                     with component: AnyHostComponent.Type,
                     node: AnyNode) {
    target.node = node
  }

  public func unmount(target: TestView, with component: AnyHostComponent.Type) {
    target.removeFromSuperview()
  }
}
