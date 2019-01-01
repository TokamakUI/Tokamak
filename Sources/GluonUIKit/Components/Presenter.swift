//
//  Presenter.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 01/01/2019.
//

import Gluon

extension Presenter: UIHostComponent {
  static func mountTarget(to parent: UITarget,
                          parentNode: Node?,
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
