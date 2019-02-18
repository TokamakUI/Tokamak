//
//  TokamakViewController.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 18/01/2019.
//

import Tokamak
import UIKit

open class TokamakViewController: UIViewController {
  private var renderer: UIKitRenderer?

  open var node: AnyNode {
    assertionFailure(
      "TokamakViewController subclass should override `node` property"
    )

    return Null.node()
  }

  open override func viewDidLoad() {
    super.viewDidLoad()

    renderer = UIKitRenderer(node, rootViewController: self)
  }
}
