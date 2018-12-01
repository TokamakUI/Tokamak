//
//  UIKitRenderer.swift
//  Gluon
//
//  Created by Max Desiatov on 07/10/2018.
//

import Foundation

protocol Renderer: class {
  func mountTarget(to parent: Any, with component: AnyBaseComponent.Type) -> Any
  func update(target: Any, with component: AnyBaseComponent.Type)
  func umount(target: Any, from parent: Any, with component: AnyBaseComponent.Type)
}

protocol UIKitBaseComponent: AnyBaseComponent {
}

struct UIKitRenderer {

}

public func render(node: Node, container: UIView) {
}
