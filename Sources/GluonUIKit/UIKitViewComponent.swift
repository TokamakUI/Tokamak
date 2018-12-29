//
//  UIKitViewComponent.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 02/12/2018.
//

import Gluon
import UIKit

public protocol UIKitViewComponent: UIKitHostComponent, HostComponent {
  associatedtype Target: UIView & Default

  static func update(_ view: Target, _ props: Props, _ children: Children)
}

extension UIKitViewComponent {
  public static func mountTarget(to parent: Any,
                                 props: AnyEquatable,
                                 children: AnyEquatable) -> Any? {
    guard let children = children.value as? Children else {
      childrenAssertionFailure()
      return nil
    }

    guard let props = props.value as? Props else {
      propsAssertionFailure()
      return nil
    }

    let target = Target()
    update(target, props, children)

    switch parent {
    case let stackView as UIStackView:
      stackView.addArrangedSubview(target)
    case let view as UIView:
      view.addSubview(target)
    default:
      parentAssertionFailure()
      ()
    }

    return target
  }

  public static func update(target: Any,
                            props: AnyEquatable,
                            children: AnyEquatable) {
    guard let target = target as? Target else {
      targetAssertionFailure()
      return
    }
    guard let children = children.value as? Children else {
      childrenAssertionFailure()
      return
    }
    guard let props = props.value as? Props else {
      propsAssertionFailure()
      return
    }

    update(target, props, children)
  }

  public static func unmount(target: Any) {
    guard let target = target as? Target else {
      targetAssertionFailure()
      return
    }

    target.removeFromSuperview()
  }
}
