//
//  UIKitRenderer.swift
//  Gluon
//
//  Created by Max Desiatov on 02/12/2018.
//

import UIKit

public protocol UIKitHostComponent: AnyHostComponent {
  static func mountTarget(to parent: Any,
                          props: AnyEquatable,
                          children: AnyEquatable) -> Any?

  static func update(target: Any,
                     props: AnyEquatable,
                     children: AnyEquatable)

  static func unmount(target: Any)
}

extension UIKitHostComponent {
  static func targetAssertionFailure(_ function: String = #function) {
    typeAssertionFailure("target", function)
  }
  static func childrenAssertionFailure(_ function: String = #function) {
    typeAssertionFailure("children", function)
  }

  static func propsAssertionFailure(_ function: String = #function) {
    typeAssertionFailure("props", function)
  }

  static func parentAssertionFailure(_ function: String = #function) {
    typeAssertionFailure("parent target", function)
  }

  private static func typeAssertionFailure(_ type: String, _ function: String) {
    assertionFailure("""
      UIKitHostComponent passed unsupported \(type) type in \(function)
    """)
  }
}

public class UIKitRenderer: Renderer {
  private var reconciler: StackReconciler?

  public init(node: Node, target: UIView) {
    reconciler = StackReconciler(node: node, target: target, renderer: self)
  }

  private func typeAssertionFailure(for type: AnyHostComponent.Type) {
    assertionFailure("""
      component type \(type) not supported by UIKitRenderer
    """)
  }

  func mountTarget(to parent: Any,
                   with component: AnyHostComponent.Type,
                   props: AnyEquatable,
                   children: AnyEquatable) -> Any? {
    guard let rendererComponent = component as? UIKitHostComponent.Type else {
      typeAssertionFailure(for: component)
      return nil
    }

    return rendererComponent.mountTarget(to: parent,
                                         props: props,
                                         children: children)
  }

  func update(target: Any,
              with component: AnyHostComponent.Type,
              props: AnyEquatable,
              children: AnyEquatable) {
    guard let rendererComponent = component as? UIKitHostComponent.Type else {
      typeAssertionFailure(for: component)
      return
    }

    rendererComponent.update(target: target,
                             props: props,
                             children: children)
  }

  func unmount(target: Any, with component: AnyHostComponent.Type) {

    guard let rendererComponent = component as? UIKitHostComponent.Type else {
      typeAssertionFailure(for: component)
      return
    }

    rendererComponent.unmount(target: target)
  }
}

