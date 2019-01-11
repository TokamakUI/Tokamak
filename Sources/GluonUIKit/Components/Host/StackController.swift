//
//  StackController.swift
//  Gluon
//
//  Created by Max Desiatov on 31/12/2018.
//

import Gluon
import UIKit

final class GluonNavigationController: UINavigationController {
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

    onPop()
  }
}

extension StackController: UIHostComponent {
  static func mountTarget(to parent: UITarget,
                          parentNode: AnyNode?,
                          props: AnyEquatable,
                          children: AnyEquatable) -> UITarget? {
    guard let props = props.value as? Props else {
      propsAssertionFailure()
      return nil
    }

    let result = ViewControllerBox(GluonNavigationController { props.onPop.value(()) })
    props.hidesBarsWhenKeyboardAppears.flatMap {
      result.containerViewController.hidesBarsWhenKeyboardAppears = $0
    }

    switch parent {
    // FIXME: this `case` handler is duplicated with `UIViewComponent`,
    // should this be generalised as a protocol?
    case let box as ViewControllerBox<UIViewController>
      where parentNode?.isSubtypeOf(ModalPresenter.self) ?? false:
      guard let props = parentNode?.props.value as? ModalPresenter.Props else {
        propsAssertionFailure()
        return nil
      }

      box.viewController.present(result.viewController,
                                 animated: props.presentAnimated,
                                 completion: nil)
    default:
      parentAssertionFailure()
    }

    return result
  }

  static func update(target: UITarget,
                     props: AnyEquatable,
                     children: AnyEquatable) {}

  static func unmount(target: UITarget) {}
}
