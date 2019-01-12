//
//  ViewBox.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import Gluon
import UIKit

class ViewBox<T: UIView>: ViewControllerBox<UIViewController> {
  let view: T

  init(_ view: T, _ viewController: UIViewController, _ node: AnyNode) {
    self.view = view

    super.init(viewController, node)
  }
}

extension ViewControllerBox: UITarget {
  var viewController: UIViewController {
    return containerViewController
  }
}
