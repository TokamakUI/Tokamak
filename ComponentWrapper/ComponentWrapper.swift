//
//  MountedComponent.swift
//  Gluon
//
//  Created by Max Desiatov on 28/11/2018.
//

protocol ComponentWrapper: class {
  var node: Node { get set }

  func mount(with reconciler: StackReconciler)

  func unmount(with reconciler: StackReconciler)

  func update(with reconciler: StackReconciler)
}
