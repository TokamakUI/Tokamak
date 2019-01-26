//
//  ViewControllerBox.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 11/01/2019.
//

import Gluon
import UIKit

class ViewControllerBox<T: UIViewController> {
  let containerViewController: T
  let node: AnyNode?

  init(_ viewController: T, _ node: AnyNode?) {
    containerViewController = viewController
    self.node = node
  }
}
