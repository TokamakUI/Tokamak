//
//  ModalPresenter.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 01/01/2019.
//

import Gluon
import UIKit

extension ModalPresenter: UIHostComponent {
  static func mountTarget(to parent: UITarget,
                          parentNode: AnyNode?,
                          props: AnyEquatable,
                          children: AnyEquatable) -> UITarget? {
    return ViewControllerBox(parent.viewController)
  }

  static func update(target: UITarget,
                     props: AnyEquatable,
                     children: AnyEquatable) {}

  static func unmount(target: UITarget) {
    target.viewController.dismiss(animated: true)
  }
}
