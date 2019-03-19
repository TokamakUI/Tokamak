//
//  TabController.swift
//  TokamakUIKit
//
//  Created by Matvii Hodovaniuk on 3/13/19.
//

import Tokamak
import UIKit

final class TokamakTabController: UITabBarController {
  init(onPop: @escaping () -> ()) {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func tabBarController(_ tabBarController: UITabBarController,
                        didSelect viewController: UIViewController) {
    print("H")
  }
}

extension TabController: UIHostComponent {
  static func mountTarget(to parent: UITarget,
                          component: UIKitRenderer.MountedHost,
                          _: UIKitRenderer) -> UITarget? {
    let props = component.node.props.value as? TabController.Props
    let result = TabControllerBox(
      component.node,
      props!,
      TokamakTabController {}
    )

    switch parent {
    case let box as ViewControllerBox<UIViewController>
      where parent.node.isSubtypeOf(ModalPresenter.self):
      guard let props = parent.node.props.value as? ModalPresenter.Props else {
        propsAssertionFailure()
        return nil
      }
      // allow children nodes to be mounted first before presenting
      DispatchQueue.main.async {
        box.viewController.present(result.viewController,
                                   animated: props.presentAnimated,
                                   completion: nil)
      }
    case let box as ViewBox<TokamakView>:
      // here
      box.addChild(result)
    case let box as ViewBox<UIView>:
      box.addChild(result)
    default:
      parentAssertionFailure()
    }

    if let selectedIndex = props?.selectedIndex {
      let index = selectedIndex.value
      DispatchQueue.main.async {
        result.containerViewController.selectedIndex = index
      }
    }

    return result
  }

  static func update(target: UITarget, node: AnyNode) {
//    if node.props.value != nil {
//      print(node.props.value)
//    }
  }

  static func unmount(target: UITarget, completion: () -> ()) {
    completion()
  }
}
