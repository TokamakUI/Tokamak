//
//  NavigationItemBox.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 09/02/2019.
//

import Gluon
import UIKit

/// A class that specializes `ViewControllerBox` to store a direct reference to
/// its parent, which allows its child targets reaching one more level up
/// across boxes hierarchy to push the view controller onto stack navigation
/// when mounted.
class NavigationItemBox: ViewControllerBox<UIViewController> {
  let parent: ViewControllerBox<GluonNavigationController>

  init(
    _ parent: ViewControllerBox<GluonNavigationController>,
    _ node: AnyNode?
  ) {
    self.parent = parent
    super.init(UIViewController(), node)
  }
}
