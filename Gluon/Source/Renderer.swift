//
//  UIKitRenderer.swift
//  Gluon
//
//  Created by Max Desiatov on 07/10/2018.
//

import Foundation

protocol Renderer: class {
  func mountTarget(to parent: Any,
                   with component: AnyHostComponent.Type,
                   props: AnyEquatable,
                   children: AnyEquatable) -> Any

  func update(target: Any,
              with component: AnyHostComponent.Type,
              props: AnyEquatable,
              children: AnyEquatable)

  func umount(target: Any,
              from parent: Any,
              with component: AnyHostComponent.Type,
              props: AnyEquatable,
              children: AnyEquatable)

  func removeAllChildren(from target: Any)
}
