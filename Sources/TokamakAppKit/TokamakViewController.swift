//
//  TokamakViewController.swift
//  TokamakAppKit
//
//  Created by Max Desiatov on 18/01/2019.
//

import AppKit
import Tokamak

open class TokamakViewController: NSViewController {
  private var renderer: AppKitRenderer?

  open var node: AnyNode {
    assertionFailure(
      "TokamakViewController subclass should override `node` property"
    )

    return Null.node()
  }

  open override func loadView() {
    view = NSView()
  }

  open override func viewDidLoad() {
    super.viewDidLoad()

    renderer = AppKitRenderer(node, rootViewController: self)
  }
}
