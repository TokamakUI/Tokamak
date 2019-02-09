//
//  StackControllerItem.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 04/02/2019.
//

import Gluon
import UIKit

extension NavigationItem: UIHostComponent {
  static func mountTarget(to parent: UITarget,
                          component: UIKitRenderer.MountedHost,
                          _: UIKitRenderer) -> UITarget? {
    return ViewControllerBox(parent.viewController, component.node)
  }

  static func update(target: UITarget, node: AnyNode) {
    guard let target = target as? ViewControllerBox<UIViewController>,
      let props = node.props.value as? NavigationItem.Props else {
      propsAssertionFailure()
      targetAssertionFailure()
      return
    }

    let item = target.viewController.navigationItem

    item.title = props.title
//    item.largeTitleDisplayMode =
  }

  static func unmount(target: UITarget) {}
}
