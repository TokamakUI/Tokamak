//
//  ViewControllerBox.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 11/01/2019.
//

import Tokamak
import UIKit

class ViewControllerBox<T: UIViewController>: UITarget {
  let containerViewController: T

  init(_ viewController: T, _ node: AnyNode) {
    containerViewController = viewController
    super.init(node: node)
  }

  override var viewController: UIViewController {
    return containerViewController
  }

  override var refTarget: Any {
    return containerViewController
  }
}
