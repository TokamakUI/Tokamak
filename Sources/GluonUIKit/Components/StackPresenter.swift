//
//  StackPresenter.swift
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

extension StackPresenter: UIHostComponent {
  static func mountTarget(to parent: UITarget,
                          parentNode: AnyNode?,
                          props: AnyEquatable,
                          children: AnyEquatable) -> UITarget? {
    guard let props = props.value as? Props else {
      propsAssertionFailure()
      return nil
    }

    let result = GluonNavigationController {}
    props.hidesBarsWhenKeyboardAppears.flatMap {
      result.hidesBarsWhenKeyboardAppears = $0
    }

    return ViewControllerBox(result)
  }

  static func update(target: UITarget,
                     props: AnyEquatable,
                     children: AnyEquatable) {}

  static func unmount(target: UITarget) {
    print("blah")
  }
}
