//
//  ListView.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 26/01/2019.
//

import Tokamak
import UIKit

extension ListView: UIViewComponent {
  public typealias RefTarget = UITableView

  static func box(
    for view: TokamakTableView,
    _ viewController: UIViewController,
    _ component: UIKitRenderer.MountedHost,
    _ renderer: UIKitRenderer
  ) -> ViewBox<TokamakTableView> {
    guard let props = component.node.props.value as? Props else {
      fatalError("incorrect props type stored in ListView node")
    }

    return TableViewBox<T>(view, viewController, component, props, renderer)
  }

  static func update(view box: ViewBox<TokamakTableView>,
                     _ props: ListView.Props,
                     _ children: Null) {
    guard let box = box as? TableViewBox<T> else {
      boxAssertionFailure("box")
      return
    }

    box.props = props
  }
}
