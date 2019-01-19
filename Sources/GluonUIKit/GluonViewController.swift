//
//  GluonViewController.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 18/01/2019.
//

import Gluon
import UIKit

open class GluonViewController: UIViewController {
  private var renderer: UIKitRenderer?

  open var node: AnyNode {
    assertionFailure(
      "GluonViewController subclass should override `node` property"
    )

    return Null.node()
  }

  open override func viewDidLoad() {
    super.viewDidLoad()

    renderer = UIKitRenderer(node, rootViewController: self)
  }
}
