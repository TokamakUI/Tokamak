//
//  StackNavigator.swift
//  Gluon
//
//  Created by Max Desiatov on 31/12/2018.
//

import Gluon
import UIKit

extension StackNavigator: UIHostComponent {
  static func mountTarget(to parent: UITarget,
                          parentNode: Node?,
                          props: AnyEquatable,
                          children: AnyEquatable) -> UITarget? {
    guard let props = props.value as? StackNavigator.Props else {
      propsAssertionFailure()
      return nil
    }

    let result = UINavigationController()
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
