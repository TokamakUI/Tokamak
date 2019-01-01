//
//  ViewBox.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import Gluon
import UIKit

class ViewControllerBox {
  let viewController: UIViewController

  init(_ viewController: UIViewController) {
    self.viewController = viewController
  }
}

class ViewBox<T: UIView>: ViewControllerBox {
  let view: T

  init(_ view: T, _ viewController: UIViewController) {
    self.view = view

    super.init(viewController)
  }
}

extension ViewControllerBox: UITarget {}
