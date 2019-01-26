//
//  ListView.swift
//  Gluon
//
//  Created by Max Desiatov on 26/01/2019.
//

import Gluon
import UIKit

extension ListView: UIViewComponent {
  static func box(
    for view: Target,
    _ viewController: UIViewController,
    _ node: AnyNode
  ) -> ViewBox<GluonTableView> {
    return TableViewBox(view, viewController, node)
  }

  static func update(view box: ViewBox<GluonTableView>,
                     _ props: ListView.Props,
                     _ children: Null) {}
}
