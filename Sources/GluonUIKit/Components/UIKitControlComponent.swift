//
//  UIKitControlComponent.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 05/12/2018.
//

import Gluon
import UIKit

public protocol UIKitControlComponent: UIKitHostComponent, HostComponent
  where Props: EventHandlerProps {
  associatedtype Target: UIControl & Default

  static func update(wrapper: ControlWrapper<Target>,
                     _ props: Props,
                     _ children: Children)

  static func wrapper(for: Target) -> ControlWrapper<Target>
}

extension UIKitControlComponent where Target == Target.DefaultValue {
  public static func wrapper(for control: Target) -> ControlWrapper<Target> {
    return ControlWrapper(control)
  }

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

    switch parent {
    case let stackView as UIStackView:
      stackView.addArrangedSubview(target)
    case let view as UIView:
      view.addSubview(target)
    default:
      parentAssertionFailure()
    }

    let result = wrapper(for: target)
    result.bind(handlers: props.handlers)
    update(wrapper: result, props, children)

    return result
  }

  public static func update(target: UIKitTarget,
                            props: AnyEquatable,
                            children: AnyEquatable) {
    guard let target = target as? ControlWrapper<Target> else {
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
    update(wrapper: target, props, children)
  }

  public static func unmount(target: UIKitTarget) {
    guard let target = target as? ControlWrapper<Target> else {
      targetAssertionFailure()
      return
    }

    target.control.removeFromSuperview()
  }
}
