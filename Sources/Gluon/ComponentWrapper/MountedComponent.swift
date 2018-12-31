//
//  MountedComponent.swift
//  Gluon
//
//  Created by Max Desiatov on 28/11/2018.
//

class MountedComponent<R: Renderer> {
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

extension Node {
  func makeMountedComponent<R: Renderer>(_ parentTarget: R.Target)
    -> MountedComponent<R> {
    switch type {
    case let .base(type):
      return MountedHostComponent(self, type, parentTarget)
    case let .composite(type):
      return MountedCompositeComponent(self, type, parentTarget)
    }
  }
}
