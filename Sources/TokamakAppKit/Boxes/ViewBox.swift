//
//  ViewBox.swift
//  TokamakAppKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import AppKit
import Tokamak

class ViewBox<T: NSView>: ViewControllerBox<NSViewController> {
  let view: T

  /// Array of constraints installed from props that configured this view
  var constraints = [NSLayoutConstraint]()

  init(_ view: T, _ viewController: NSViewController, _ node: AnyNode) {
    self.view = view

    super.init(viewController, node)
  }

  override var refTarget: Any {
    return view
  }
}
