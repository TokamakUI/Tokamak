//
//  UIKitRenderer.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 02/12/2018.
//

import Gluon
import UIKit

// FIXME: working around "Couldn't lookup symbols: protocol witness table"
// compiler bug
let _ModalPresenterWitnessTableHack: UIHostComponent.Type = ModalPresenter.self
let _StackControllerWitnessTableHack: UIHostComponent.Type =
  StackController.self

// Type-erased version of `ViewControllerBox` to avoid generics leaking out.
public protocol UITarget {
  var node: AnyNode? { get }
  var viewController: UIViewController { get }
}

/// UIKitRenderer is an implementation of `Renderer` with UIKit as a target.
class UIKitRenderer: Renderer {
  private var reconciler: StackReconciler<UIKitRenderer>?
  private weak var rootViewController: UIViewController!

  init(_ node: AnyNode, rootViewController: UIViewController) {
    self.rootViewController = rootViewController
    reconciler = StackReconciler(
      node: node,
      target: ViewBox(rootViewController.view, rootViewController, node),
      renderer: self
    )
  }

  private func typeAssertionFailure(for type: AnyHostComponent.Type) {
    assertionFailure("""
      component type \(type) not supported by UIKitRenderer
    """)
  }

  func mountTarget(to parent: UITarget,
                   parentNode: AnyNode?,
                   with component: AnyHostComponent.Type,
                   node: AnyNode) -> UITarget? {
    guard let rendererComponent = component as? UIHostComponent.Type else {
      typeAssertionFailure(for: component)
      return nil
    }

    return rendererComponent.mountTarget(to: parent,
                                         node: node)
  }

  func update(target: UITarget,
              with component: AnyHostComponent.Type,
              node: AnyNode) {
    guard let rendererComponent = component as? UIHostComponent.Type else {
      typeAssertionFailure(for: component)
      return
    }

    rendererComponent.update(target: target,
                             node: node)
  }

  func unmount(target: UITarget,
               with component: AnyHostComponent.Type) {
    guard let rendererComponent = component as? UIHostComponent.Type else {
      typeAssertionFailure(for: component)
      return
    }

    rendererComponent.unmount(target: target)
  }
}
