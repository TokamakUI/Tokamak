//
//  UIKitRenderer.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 02/12/2018.
//

import Gluon
import UIKit

public protocol UITarget {}

public class UIKitRenderer: Renderer {
  private var reconciler: StackReconciler<UIKitRenderer>?
  private let rootViewController: UIViewController

  public init(node: Node, rootViewController: UIViewController) {
    self.rootViewController = rootViewController
    reconciler = StackReconciler(
      node: node,
      target: ViewBox(rootViewController.view),
      renderer: self
    )
  }

  private func typeAssertionFailure(for type: AnyHostComponent.Type) {
    assertionFailure("""
      component type \(type) not supported by UIKitRenderer
    """)
  }

  public func mountTarget(to parent: UITarget,
                          with component: AnyHostComponent.Type,
                          props: AnyEquatable,
                          children: AnyEquatable) -> UITarget? {
    guard let rendererComponent = component as? UIHostComponent.Type else {
      typeAssertionFailure(for: component)
      return nil
    }

    return rendererComponent.mountTarget(to: parent,
                                         props: props,
                                         children: children)
  }

  public func update(target: UITarget,
                     with component: AnyHostComponent.Type,
                     props: AnyEquatable,
                     children: AnyEquatable) {
    guard let rendererComponent = component as? UIHostComponent.Type else {
      typeAssertionFailure(for: component)
      return
    }

    rendererComponent.update(target: target,
                             props: props,
                             children: children)
  }

  public func unmount(target: UITarget,
                      with component: AnyHostComponent.Type) {
    guard let rendererComponent = component as? UIHostComponent.Type else {
      typeAssertionFailure(for: component)
      return
    }

    rendererComponent.unmount(target: target)
  }
}
