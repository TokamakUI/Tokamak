//
//  TabController.swift
//  TokamakUIKit
//
//  Created by Matvii Hodovaniuk on 3/13/19.
//

import Tokamak
import UIKit

final class TokamakTabController: UITabBarController {
  /// Used to prevent calling `onPop` if this navigation view controller is not
  /// mounted yet
  var isMounted = false

  init(onPop: @escaping () -> ()) {
    super.init(nibName: nil, bundle: nil)
//    let tabBarCnt = UITabBarController()
//    let firstVc = UIViewController()
//    firstVc.title = "First"
//    firstVc.view.backgroundColor = UIColor.red
//    firstVc.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "HomeTab"), tag: 0)
//
//    let secondVc = UIViewController()
//    secondVc.title = "Second"
//    secondVc.view.backgroundColor = UIColor.green
//    secondVc.tabBarItem = UITabBarItem(title: "Location", image: UIImage(named: "Location"), tag: 1)
//
//    let controllerArray = [firstVc, secondVc]
//    tabBarCnt.viewControllers = controllerArray.map { UINavigationController(rootViewController: $0) }
//
//    view.addSubview(tabBarCnt.view)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func didMove(toParent parent: UIViewController?) {
    super.didMove(toParent: parent)

    guard isMounted else { return }
//        onPop()
  }
}

extension TabController: UIHostComponent {
  static func mountTarget(to parent: UITarget,
                          component: UIKitRenderer.MountedHost,
                          _: UIKitRenderer) -> UITarget? {
    let result = ViewControllerBox(TokamakTabController {}, component.node)

    switch parent {
    case let box as ViewControllerBox<UIViewController>:
      guard let props = parent.node.props.value as? TabController.Props else {
        propsAssertionFailure()
        return nil
      }

      // allow children nodes to be mounted first before presenting
      DispatchQueue.main.async {
        box.viewController.present(result.viewController,
                                   animated: props.isAnimated,
                                   completion: nil)
      }
    case let box as ViewBox<UIView>:
      result.viewController.willMove(toParent: box.viewController)
      // FIXME: replace with auto layout constraints
      result.viewController.view.frame = box.view.frame
      box.view.addSubview(result.viewController.view)
      box.viewController.addChild(result.viewController)
      result.viewController.didMove(toParent: box.viewController)
      result.containerViewController.isMounted = true
    default:
      parentAssertionFailure()
    }

    return result
  }

  static func update(target: UITarget, node: AnyNode) {}

  static func unmount(target: UITarget, completion: () -> ()) {
    completion()
  }
}
