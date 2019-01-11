//
//  ViewBox.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import UIKit

class ViewBox<T: UIView>: ViewControllerBox<UIViewController> {
  let view: T

  init(_ view: T, _ viewController: UIViewController) {
    self.view = view

    super.init(viewController)
  }
}

extension ViewControllerBox: UITarget {
  var viewController: UIViewController {
    return containerViewController
  }
}
