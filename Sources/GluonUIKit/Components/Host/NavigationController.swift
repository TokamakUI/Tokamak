//
//  StackController.swift
//  Gluon
//
//  Created by Max Desiatov on 31/12/2018.
//

import Gluon
import UIKit

final class GluonNavigationController: UINavigationController {
  /// Used to prevent calling `onPop` if this navigation view controller is not
  /// mounted yet
  var isMounted = false
  private let onPop: () -> ()

  init(onPop: @escaping () -> ()) {
    self.onPop = onPop

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func didMove(toParent parent: UIViewController?) {
    super.didMove(toParent: parent)

    guard isMounted else { return }
    onPop()
  }
}

extension NavigationController: UIHostComponent {
  static func mountTarget(to parent: UITarget,
                          component: UIKitRenderer.MountedHost,
                          _: UIKitRenderer) -> UITarget? {
    guard let props = component.node.props.value as? Props else {
      propsAssertionFailure()
      return nil
    }

    let result = ViewControllerBox(GluonNavigationController {
      props.onPop.value(())
    }, component.node)
    props.hidesBarsWhenKeyboardAppears.flatMap {
      result.containerViewController.hidesBarsWhenKeyboardAppears = $0
    }

    result.containerViewController.navigationBar.prefersLargeTitles =
      props.prefersLargeTitles

    switch parent {
    // FIXME: this `case` handler is duplicated with `UIViewComponent`,
    // should this be generalised as a protocol?
    case let box as ViewControllerBox<UIViewController>
      where parent.node?.isSubtypeOf(ModalPresenter.self) ?? false:
      guard let props = parent.node?.props.value as? ModalPresenter.Props else {
        propsAssertionFailure()
        return nil
      }

      // allow children nodes to be mounted first before presenting
      DispatchQueue.main.async {
        box.viewController.present(result.viewController,
                                   animated: props.presentAnimated,
                                   completion: nil)
      }
    case let box as ViewBox<UIView>:
      result.viewController.willMove(toParent: box.viewController)
      // FIXME: replace with constraints
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

  static func unmount(target: UITarget) {}
}
