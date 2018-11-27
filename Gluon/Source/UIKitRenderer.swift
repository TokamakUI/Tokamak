//
//  UIKitRenderer.swift
//  Gluon
//
//  Created by Max Desiatov on 07/10/2018.
//

import Foundation

protocol Renderer {
  func mountTarget(to parent: Any, with component: RendererBaseComponent) -> Any
  func update(target: Any, with component: RendererBaseComponent)
  func umount(target: Any, from parent: Any, with component: RendererBaseComponent)
}

protocol Reconciler {
  func reconcile(node: Node)
}

protocol RendererBaseComponent {

}

protocol UIKitBaseComponent: RendererBaseComponent {
}

struct StackReconciler: Reconciler {
  

  func reconcile(node: Node) {
  }
}

struct UIKitRenderer {

}

public func render(node: Node, container: UIView) {
}
