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
                          props: AnyEquatable,
                          children: AnyEquatable) -> UITarget? {
    return nil
//    guard let props = props.value as? StackNavigator.Props else {
//      propsAssertionFailure()
//      return nil
//    }
//
//    let result = UINavigationController()
//    result.hidesBarsWhenKeyboardAppears = props.hidesBarsWhenKeyboardAppears
//    return result
  }

  static func update(target: UITarget,
                     props: AnyEquatable,
                     children: AnyEquatable) {}

  static func unmount(target: UITarget) {}
}
