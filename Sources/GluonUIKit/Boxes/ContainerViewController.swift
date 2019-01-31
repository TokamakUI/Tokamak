//
//  ContainerViewController.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 01/01/2019.
//

import Gluon
import UIKit

final class ContainerViewController: UIViewController {
  private let contained: UIView

  init(contained: UIView) {
    self.contained = contained

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = contained
  }
}
