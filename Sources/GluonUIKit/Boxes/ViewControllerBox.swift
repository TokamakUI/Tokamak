//
//  ViewControllerBox.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 11/01/2019.
//

import Gluon
import UIKit

class ViewControllerBox<T: UIViewController>: UITarget {
  let containerViewController: T

  init(_ viewController: T, _ node: AnyNode?) {
    containerViewController = viewController
    super.init(node: node)
  }

  override var viewController: UIViewController {
    return containerViewController
  }
}
