//
//  UIKitRenderer.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 02/12/2018.
//

import Gluon
import UIKit

public protocol UIKitTarget {}

extension UIView: UIKitTarget {}

extension UIViewController: UIKitTarget {}

public class UIKitRenderer: Renderer {
  private var reconciler: StackReconciler<UIKitRenderer>?
  private let rootViewController: UIViewController

  public init(node: Node, rootViewController: UIViewController) {
    self.rootViewController = rootViewController
    reconciler = StackReconciler(
      node: node,
      target: rootViewController.view,
      renderer: self
    )
  }

  private func typeAssertionFailure(for type: AnyHostComponent.Type) {
    assertionFailure("""
      component type \(type) not supported by UIKitRenderer
    """)
  }

  public func mountTarget(to parent: UIKitTarget,
                          with component: AnyHostComponent.Type,
                          props: AnyEquatable,
                          children: AnyEquatable) -> UIKitTarget? {
    guard let rendererComponent = component as? UIKitHostComponent.Type else {
      typeAssertionFailure(for: component)
      return nil
    }

    return rendererComponent.mountTarget(to: parent,
                                         props: props,
                                         children: children)
  }

  public func update(target: UIKitTarget,
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

  public func unmount(target: UIKitTarget,
                      with component: AnyHostComponent.Type) {
    guard let rendererComponent = component as? UIKitHostComponent.Type else {
      typeAssertionFailure(for: component)
      return
    }

    rendererComponent.unmount(target: target)
  }
}
