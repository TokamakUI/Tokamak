//
//  TestRenderer.swift
//  GluonTestRenderer
//
//  Created by Max Desiatov on 21/12/2018.
//

import Gluon

public class TestRenderer: Renderer {
  private var reconciler: StackReconciler<TestRenderer>?

  public var rootTarget: TestView? {
    return reconciler?.rootTarget
  }

  public init(_ node: Node) {
    reconciler = StackReconciler(node: node,
                                 target: TestView(props: AnyEquatable(Null())),
                                 renderer: self)
  }

  public func mountTarget(to parent: TestView,
                          with component: AnyHostComponent.Type,
                          props: AnyEquatable,
                          children: AnyEquatable) -> TestView? {
    let result = TestView(props: props)
    parent.add(subview: result)

    return result
  }

  public func update(target: TestView,
                     with component: AnyHostComponent.Type,
                     props: AnyEquatable,
                     children: AnyEquatable) {
    target.props = props
  }

  public func unmount(target: TestView, with component: AnyHostComponent.Type) {
    target.removeFromSuperview()
  }
}
