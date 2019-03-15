//
//  TabItem.swift
//  TokamakUIKit
//
//  Created by Matvii Hodovaniuk on 3/14/19.
//

import Tokamak
import UIKit

extension TabItem: UIHostComponent {
  static func mountTarget(to parent: UITarget,
                          component: UIKitRenderer.MountedHost,
                          _: UIKitRenderer) -> UITarget? {
    guard
      let parent = parent as? ViewControllerBox<TokamakTabController>
    else {
      parentAssertionFailure()
      return nil
    }

    guard
      let parentProps = parent.node.props.value as? TabController.Props
    else {
      propsAssertionFailure()
      return nil
    }

    let viewController = UIViewController()
    let result = ViewControllerBox(viewController, component.node)
    if var viewControllers = parent.containerViewController.viewControllers {
      viewControllers.append(viewController)
      parent.containerViewController.setViewControllers(
        viewControllers,
        animated: parentProps.isAnimated
      )
    } else {
      parent.containerViewController.setViewControllers(
        [viewController],
        animated: parentProps.isAnimated
      )
    }

    return result
  }

  static func update(target: UITarget, node: AnyNode) {
    guard let target = target as? ViewControllerBox<UIViewController> else {
      targetAssertionFailure()
      return
    }
    guard let props = node.props.value as? TabItem.Props else {
      propsAssertionFailure()
      return
    }

    let item = target.viewController.tabBarItem

    item?.title = props.title
//    item.largeTitleDisplayMode = .init(mode: props.titleMode)
  }

  static func unmount(target: UITarget, completion: () -> ()) { completion() }
}
