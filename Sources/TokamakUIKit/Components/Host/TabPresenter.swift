//
//  TabPresenter.swift
//  TokamakUIKit
//
//  Created by Matvii Hodovaniuk on 3/13/19.
//

import Tokamak
import UIKit

final class TokamakTabPresenter: UITabBarController {
  init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension TabPresenter: UIHostComponent, RefComponent {
  public typealias RefTarget = UITabBarController

  static func mountTarget(to parent: UITarget,
                          component: UIKitRenderer.MountedHost,
                          _: UIKitRenderer) -> UITarget? {
    let props = component.node.props.value as? TabPresenter.Props
    let result = TabBarControllerBox(
      component.node,
      props!,
      TokamakTabPresenter()
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

  static func update(target: UITarget, node: AnyNode) {}

  static func unmount(
    target: UITarget,
    from parent: UITarget,
    completion: @escaping () -> ()
  ) {
    completion()
  }
}
