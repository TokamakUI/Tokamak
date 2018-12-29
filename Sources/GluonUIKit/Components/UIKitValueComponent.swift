//
//  UIKitValueComponent.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import Gluon
import UIKit

public protocol UIKitValueComponent: UIKitControlComponent
  where Props: ValueControlProps, Target: ValueStorage,
  Props.Value == Target.Value {
  static func update(valueControl: Target, _ props: Props, _ children: Children)
}

extension UIKitValueComponent {
  public static func wrapper(for control: Target) -> ControlWrapper<Target> {
    return ValueControlWrapper(control)
  }

  public static func update(wrapper: ControlWrapper<Target>,
                            _ props: Props,
                            _ children: Children) {
    update(valueControl: wrapper.control, props, children)

    guard let wrapper = wrapper as? ValueControlWrapper<Target> else { return }

    wrapper.value = props.value
    wrapper.bind(valueChangedHandler: props.valueHandler)
  }
}
