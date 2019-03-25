////
////  TabBarControllBox.swift
////  TokamakUIKit
////
////  Created by Matvii Hodovaniuk on 3/15/19.
////

import Tokamak
import UIKit

private final class Delegate<T: UITabBarController>:
  NSObject,
  UITabBarControllerDelegate {
  private let selectedIndex: State<Int>?

  func tabBarController(
    _ tabBarController: UITabBarController,
    didSelect viewController: UIViewController
  ) {
    selectedIndex?.set(
      (tabBarController.viewControllers?.firstIndex(of: viewController)!)!
    )
  }

  init(_ props: TabPresenter.Props) {
    selectedIndex = props.selectedIndex
  }
}

class TabBarControllerBox: ViewControllerBox<UITabBarController> {
  // this delegate stays as a constant and doesn't create a reference cycle
  // swiftlint:disable:next weak_delegate
  private let delegate: Delegate<UITabBarController>

  init(
    _ node: AnyNode,
    _ props: TabPresenter.Props,
    _ viewController: TokamakTabController
  ) {
    delegate = Delegate(props)
    viewController.delegate = delegate
    super.init(viewController, node)
  }
}
