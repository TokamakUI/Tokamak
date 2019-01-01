//
//  UIControlComponent.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 05/12/2018.
//

import Gluon
import UIKit

protocol UIControlComponent: UIHostComponent, HostComponent
  where Props: EventHandlerProps {
  associatedtype Target: UIControl & Default

  static func update(controlBox: ControlBox<Target>,
                     _ props: Props,
                     _ children: Children)

  static func controlBox(for: Target) -> ControlBox<Target>
}

extension UIControlComponent where Target == Target.DefaultValue {
  static func controlBox(for control: Target) -> ControlBox<Target> {
    return ControlBox(control)
  }

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

    let target = Target.defaultValue

    switch parent {
    case let stackView as UIStackView:
      stackView.addArrangedSubview(target)
    case let view as UIView:
      view.addSubview(target)
    default:
      parentAssertionFailure()
    }

    let result = controlBox(for: target)
    result.bind(handlers: props.handlers)
    update(controlBox: result, props, children)

    return result
  }

  static func update(target: UITarget,
                     props: AnyEquatable,
                     children: AnyEquatable) {
    guard let target = target as? ControlBox<Target> else {
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

    target.bind(handlers: props.handlers)
    update(controlBox: target, props, children)
  }

  static func unmount(target: UITarget) {
    guard let target = target as? ControlBox<Target> else {
      targetAssertionFailure()
      return
    }

    target.view.removeFromSuperview()
  }
}
