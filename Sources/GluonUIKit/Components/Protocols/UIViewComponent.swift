//
//  UIKitViewComponent.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 02/12/2018.
//

import Gluon
import UIKit

public protocol UIViewComponent: UIHostComponent, HostComponent {
  associatedtype Target: UIView & Default

  static func update(_ view: Target, _ props: Props, _ children: Children)
}

private func applyStyle<T: UIView, P: StyleProps>(_ target: T, _ props: P) {
  guard let style = props.style else {
    return
  }

  style.alpha.flatMap { target.alpha = CGFloat($0) }
  style.backgroundColor.flatMap { target.backgroundColor = UIColor($0) }
  style.clipsToBounds.flatMap { target.clipsToBounds = $0 }
  style.center.flatMap { target.center = CGPoint($0) }
  style.frame.flatMap { target.frame = CGRect($0) }
  style.isHidden.flatMap { target.isHidden = $0 }
}

extension UIViewComponent where Target == Target.DefaultValue,
  Props: StyleProps {
  public static func mountTarget(to parent: UIKitTarget,
                                 props: AnyEquatable,
                                 children: AnyEquatable) -> UIKitTarget? {
    guard let children = children.value as? Children else {
      childrenAssertionFailure()
      return nil
    }

    guard let props = props.value as? Props else {
      propsAssertionFailure()
      return nil
    }

    let target = Target.defaultValue
    applyStyle(target, props)
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

  public static func update(target: UIKitTarget,
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

    applyStyle(target, props)

    update(target, props, children)
  }

  public static func unmount(target: UIKitTarget) {
    guard let target = target as? Target else {
      targetAssertionFailure()
      return
    }

    target.removeFromSuperview()
  }
}
