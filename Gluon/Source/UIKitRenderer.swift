//
//  UIKitRenderer.swift
//  Gluon
//
//  Created by Max Desiatov on 07/10/2018.
//

import Foundation

protocol Renderer: class {
  func mountTarget(to parent: Any, with component: RendererBaseComponent.Type) -> Any
  func update(target: Any, with component: RendererBaseComponent.Type)
  func umount(target: Any, from parent: Any, with component: RendererBaseComponent.Type)
}

protocol RendererBaseComponent {

}

protocol UIKitBaseComponent: RendererBaseComponent {
}

struct UIKitRenderer {

}

public func render(node: Node, container: UIView) {
}
