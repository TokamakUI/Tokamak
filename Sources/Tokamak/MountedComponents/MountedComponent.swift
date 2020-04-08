//
//  MountedComponent.swift
//  Tokamak
//
//  Created by Max Desiatov on 28/11/2018.
//

public class MountedComponent<R: Renderer> {
  public internal(set) var node: AnyView
  public let viewType: Any.Type

  init(_ node: AnyView) {
    self.node = node
    viewType = node.type
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

extension View {
  func makeMountedComponent<R: Renderer>(_ parentTarget: R.TargetType)
    -> MountedComponent<R> {
    if Body.self is Never.Type {
      return MountedHostComponent(AnyView(self), parentTarget)
    } else {
      return MountedCompositeComponent(AnyView(self), parentTarget)
    }
  }
}
