//
//  NavigationItemBox.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 12/03/2019.
//

import Tokamak
import UIKit

final class NavigationItemBox: ViewControllerBox<UIViewController> {
  let renderer: UIKitRenderer

  init(
    _ renderer: UIKitRenderer,
    _ viewController: UIViewController,
    _ node: AnyNode
  ) {
    self.renderer = renderer

    super.init(viewController, node)
  }

  override var refTarget: Any {
    return containerViewController.navigationItem
  }
}
