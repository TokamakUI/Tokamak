//
//  MountedNull.swift
//  Tokamak
//
//  Created by Max Desiatov on 05/01/2019.
//

final class MountedNull<R: Renderer>: MountedComponent<R> {
  override func mount(with reconciler: StackReconciler<R>) {}

  override func unmount(with reconciler: StackReconciler<R>) {}

  override func update(with reconciler: StackReconciler<R>) {}
}
