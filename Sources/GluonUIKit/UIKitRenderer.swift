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

let _ListViewWitnessTableHack: UIHostComponent.Type = ListView<Provider>.self

struct Provider: SimpleCellProvider {
  static func cell(
    props: Provider.Props, item: Int, path: CellPath
  ) -> AnyNode {
    return Null.node()
  }

  typealias Props = Null

  typealias Model = [[Int]]
}

public class UITarget {
  let node: AnyNode?

  init(node: AnyNode?) {
    self.node = node
  }

  var viewController: UIViewController {
    fatalError("viewController should be overriden in UITarget subclass")
  }
}

/// UIKitRenderer is an implementation of `Renderer` with UIKit as a target.
final class UIKitRenderer: Renderer {
  private(set) var reconciler: StackReconciler<UIKitRenderer>?
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

  func mountTarget(
    to parent: UITarget,
    with component: UIKitRenderer.MountedHost
  ) -> UITarget? {
    guard let rendererComponent = component.type as? UIHostComponent.Type else {
      typeAssertionFailure(for: component.type)
      return nil
    }

    return rendererComponent.mountTarget(to: parent,
                                         component: component,
                                         self)
  }

  func update(target: UITarget,
              with component: UIKitRenderer.MountedHost) {
    guard let rendererComponent = component.type as? UIHostComponent.Type else {
      typeAssertionFailure(for: component.type)
      return
    }

    rendererComponent.update(target: target,
                             node: component.node)
  }

  func unmount(target: UITarget,
               with component: UIKitRenderer.MountedHost) {
    guard let rendererComponent = component.type as? UIHostComponent.Type else {
      typeAssertionFailure(for: component.type)
      return
    }

    rendererComponent.unmount(target: target)
  }
}
