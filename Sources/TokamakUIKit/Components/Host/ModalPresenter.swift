//
//  ModalPresenter.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 01/01/2019.
//

import Tokamak
import UIKit

extension ModalPresenter: UIHostComponent {
  static func mountTarget(to parent: UITarget,
                          component: UIKitRenderer.MountedHost,
                          _: UIKitRenderer) -> UITarget? {
    return ViewControllerBox(parent.viewController, component.node)
  }

  static func update(target: UITarget,
                     node: AnyNode) {
    // FIXME: update presentation-related props on the target here
  }

  static func unmount(target: UITarget, completion: @escaping () -> ()) {
    target.viewController.dismiss(animated: true) { completion() }
  }
}
