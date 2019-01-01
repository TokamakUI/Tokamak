//
//  UIValueComponent.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import Gluon
import UIKit

public protocol UIValueComponent: UIControlComponent
  where Props: ValueControlProps, Target: ValueStorage,
  Props.Value == Target.Value {
  static func update(valueControl: Target, _ props: Props, _ children: Children)
}

extension UIValueComponent {
  public static func wrapper(for control: Target) -> ControlBox<Target> {
    return ValueControlBox(control)
  }

  public static func update(wrapper: ControlBox<Target>,
                            _ props: Props,
                            _ children: Children) {
    update(valueControl: wrapper.control, props, children)

    guard let wrapper = wrapper as? ValueControlBox<Target> else { return }

    wrapper.value = props.value
    wrapper.bind(valueChangedHandler: props.valueHandler)
  }
}
