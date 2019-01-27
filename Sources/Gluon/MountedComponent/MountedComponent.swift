//
//  MountedComponent.swift
//  Gluon
//
//  Created by Max Desiatov on 28/11/2018.
//

public class MountedComponent<R: Renderer> {
  public internal(set) var node: AnyNode
  private(set) weak var parent: MountedComponent<R>?

  init(_ node: AnyNode, _ parent: MountedComponent<R>?) {
    self.node = node
    self.parent = parent
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
  func makeMountedComponent<R: Renderer>(
    _ parent: MountedComponent<R>?,
    _ parentTarget: R.Target
  )
    -> MountedComponent<R> {
    switch type {
    case let .host(type):
      return MountedHostComponent(self, type, parent, parentTarget)
    case let .composite(type):
      return MountedCompositeComponent(self, type, parent, parentTarget)
    case .null:
      return MountedNull(self, parent)
    }
  }
}
