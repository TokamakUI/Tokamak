//
//  TestRenderer.swift
//  GluonTestRenderer
//
//  Created by Max Desiatov on 21/12/2018.
//

import Gluon

public class TestRenderer: Renderer {
  private var reconciler: StackReconciler?

  public init(_ node: Node) {
    reconciler = StackReconciler(node: node,
                                 target: TestView(props: AnyEquatable(Null())),
                                 renderer: self)
  }

  public func mountTarget(to parent: Any,
                          with component: AnyHostComponent.Type,
                          props: AnyEquatable,
                          children: AnyEquatable) -> Any? {
    guard let parent = parent as? TestView else {
      assertionFailure("parent of wrong type passed to \(#function)")
      return nil
    }

    let result = TestView(props: props)
    parent.add(subview: result)

    return result
  }

  public func update(target: Any,
                     with component: AnyHostComponent.Type,
                     props: AnyEquatable,
                     children: AnyEquatable) {
    guard let target = target as? TestView else {
      assertionFailure("parent of wrong type passed to \(#function)")
      return
    }

    target.props = props
  }

  public func unmount(target: Any, with component: AnyHostComponent.Type) {
    guard let target = target as? TestView else {
      assertionFailure("parent of wrong type passed to \(#function)")
      return
    }

    target.removeFromSuperview()
  }
}
