//
//  MountedComponent.swift
//  Tokamak
//
//  Created by Max Desiatov on 28/11/2018.
//

public class MountedComponent<R: Renderer> {
  public internal(set) var node: AnyNode

  init(_ node: AnyNode) {
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

extension AnyNode {
  func makeMountedComponent<R: Renderer>(_ parentTarget: R.TargetType)
    -> MountedComponent<R> {
    switch type {
    case let .host(type):
      return MountedHostComponent(self, type, parentTarget)
    case let .composite(type):
      return MountedCompositeComponent(self, type, parentTarget)
    case .null:
      return MountedNull(self)
    }
  }
}
