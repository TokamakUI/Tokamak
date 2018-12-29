//
//  MountedComponent.swift
//  Gluon
//
//  Created by Max Desiatov on 28/11/2018.
//

class ComponentWrapper<R: Renderer> {
  var node: Node

  init(_ node: Node) {
    self.node = node
  }

  func mount(with reconciler: StackReconciler<R>) {
    fatalError("implement \(#function) in subclass")
  }

  func unmount(with reconciler: StackReconciler<R>) {
    fatalError("implement \(#function) in subclass")
  }

  func update(with reconciler: StackReconciler<R>) {
    fatalError("implement \(#function) in subclass")
  }
}
