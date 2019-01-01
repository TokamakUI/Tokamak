//
//  UIKitViewComponent.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 02/12/2018.
//

import Gluon
import UIKit

protocol UIViewComponent: UIHostComponent, HostComponent {
  associatedtype Target: UIView & Default

  static func update(_ box: ViewBox<Target>,
                     _ props: Props,
                     _ children: Children)
}

private func applyStyle<T: UIView, P: StyleProps>(_ target: ViewBox<T>,
                                                  _ props: P) {
  guard let style = props.style else {
    return
  }

  let view = target.view

  style.alpha.flatMap { view.alpha = CGFloat($0) }
  style.backgroundColor.flatMap { view.backgroundColor = UIColor($0) }
  style.clipsToBounds.flatMap { view.clipsToBounds = $0 }
  style.center.flatMap { view.center = CGPoint($0) }
  style.frame.flatMap { view.frame = CGRect($0) }
  style.isHidden.flatMap { view.isHidden = $0 }
}

extension UIViewComponent where Target == Target.DefaultValue,
  Props: StyleProps {
  static func mountTarget(to parent: UITarget,
                          props: AnyEquatable,
                          children: AnyEquatable) -> UITarget? {
    guard let children = children.value as? Children else {
      childrenAssertionFailure()
      return nil
    }

    guard let props = props.value as? Props else {
      propsAssertionFailure()
      return nil
    }

    let target = ViewBox<Target>.defaultValue
    applyStyle(target, props)
    update(target, props, children)

    print(parent)
    switch parent {
    case let box as ViewBox<GluonUIStackView>:
      box.view.addArrangedSubview(target.view)
    case let box as ViewBox<UIView>:
      box.view.addSubview(target.view)
    default:
      parentAssertionFailure()
      ()
    }

    return target
  }

  static func update(target: UITarget,
                     props: AnyEquatable,
                     children: AnyEquatable) {
    guard let target = target as? ViewBox<Target> else {
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

  static func unmount(target: UITarget) {
    guard let target = target as? Target else {
      targetAssertionFailure()
      return
    }

    target.removeFromSuperview()
  }
}
