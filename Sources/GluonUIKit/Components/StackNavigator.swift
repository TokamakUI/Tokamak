//
//  StackNavigator.swift
//  Gluon
//
//  Created by Max Desiatov on 31/12/2018.
//

import Gluon
import UIKit

extension StackNavigator: UIHostComponent {
  public static func mountTarget(to parent: UIKitTarget,
                                 props: AnyEquatable,
                                 children: AnyEquatable) -> UIKitTarget? {
    guard let props = props.value as? StackNavigator.Props else {
      propsAssertionFailure()
      return nil
    }

    let result = UINavigationController()
    result.hidesBarsWhenKeyboardAppears = props.hidesBarsWhenKeyboardAppears
    return result
  }

  public static func update(target: UIKitTarget,
                            props: AnyEquatable,
                            children: AnyEquatable) {}

  public static func unmount(target: UIKitTarget) {}
}
