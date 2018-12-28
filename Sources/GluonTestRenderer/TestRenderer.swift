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
    reconciler = StackReconciler(node: node, target: TestView(props: AnyEquatable(Null())), renderer: self)
  }

  public func mountTarget(to _: Any,
                          with _: AnyHostComponent.Type,
                          props _: AnyEquatable, children _: AnyEquatable) -> Any? {
    return nil
  }

  public func update(target _: Any,
                     with _: AnyHostComponent.Type,
                     props _: AnyEquatable,
                     children _: AnyEquatable) {}

  public func unmount(target _: Any, with _: AnyHostComponent.Type) {}
}
