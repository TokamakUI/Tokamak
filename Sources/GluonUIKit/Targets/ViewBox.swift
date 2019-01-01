//
//  ViewBox.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import Gluon
import UIKit

class ViewBox<T: UIView> {
  let view: T
  let viewController: UIViewController

  init(_ view: T, _ viewController: UIViewController) {
    self.view = view
    self.viewController = viewController
  }
}

extension ViewBox: UITarget {}
