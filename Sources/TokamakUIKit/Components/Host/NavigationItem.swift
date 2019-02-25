//
//  StackControllerItem.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 04/02/2019.
//

import Tokamak
import UIKit

extension UINavigationItem.LargeTitleDisplayMode {
  init(mode: NavigationItem.Props.TitleMode) {
    switch mode {
    case .automatic:
      self = .automatic
    case .large:
      self = .always
    case .standard:
      self = .never
    }
  }
}

extension NavigationItem: UIHostComponent {
  static func mountTarget(to parent: UITarget,
                          component: UIKitRenderer.MountedHost,
                          _: UIKitRenderer) -> UITarget? {
    guard
      let parent = parent as? ViewControllerBox<TokamakNavigationController>
    else {
      parentAssertionFailure()
      return nil
    }

    guard
      let parentProps = parent.node.props.value as? NavigationController.Props
    else {
      propsAssertionFailure()
      return nil
    }

    let viewController = UIViewController()
    let result = ViewControllerBox(viewController, component.node)

    parent.containerViewController.pushViewController(
      viewController,
      animated: parentProps.pushAnimated
    )

    return result
  }

  static func update(target: UITarget, node: AnyNode) {
    guard let target = target as? ViewControllerBox<UIViewController> else {
      targetAssertionFailure()
      return
    }
    guard let props = node.props.value as? NavigationItem.Props else {
      propsAssertionFailure()
      return
    }

    let item = target.viewController.navigationItem

    item.title = props.title
    item.largeTitleDisplayMode = .init(mode: props.titleMode)
  }

  static func unmount(target: UITarget, completion: () -> ()) { completion() }
}
