//
//  ViewControllerBox.swift
//  TokamakAppKit
//
//  Created by Max Desiatov on 11/01/2019.
//

import AppKit
import Tokamak

class ViewControllerBox<T: NSViewController>: NSTarget {
  let containerViewController: T

  init(_ viewController: T, _ node: AnyView) {
    containerViewController = viewController
    super.init(node: node)
  }

  override var viewController: NSViewController {
    containerViewController
  }

  override var refTarget: Any {
    containerViewController
  }
}
