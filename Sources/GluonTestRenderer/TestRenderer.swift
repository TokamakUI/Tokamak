//
//  TestRenderer.swift
//  GluonTestRenderer
//
//  Created by Max Desiatov on 21/12/2018.
//

import Gluon

public class TestRenderer: Renderer {
  private var reconciler: StackReconciler?

  public init(node: Node) {
    reconciler = StackReconciler(node: node, target: TestView(props: Null()), renderer: self)
  }

  public func mountTarget(to parent: Any,
                          with component: AnyHostComponent.Type,
                          props: AnyEquatable, children: AnyEquatable) -> Any? {
    return nil
  }

  public func update(target: Any,
                     with component: AnyHostComponent.Type,
                     props: AnyEquatable,
                     children: AnyEquatable) {

  }

  public func unmount(target: Any, with component: AnyHostComponent.Type) {

  }
}
