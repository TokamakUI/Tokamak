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
    // FIXME: update props related to navigation item on the target here
  }

  static func unmount(target: UITarget) {}
}
