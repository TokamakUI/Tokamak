//
//  UIValueComponent.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import Gluon
import UIKit

protocol UIValueComponent: UIControlComponent
  where Props: ValueControlProps, Target: ValueStorage,
  Props.Value == Target.Value {
  static func update(valueBox: ValueControlBox<Target>,
                     _ props: Props,
                     _ children: Children)
}

extension UIValueComponent {
  static func controlBox(for control: Target) -> ControlBox<Target> {
    return ValueControlBox(control)
  }

  static func update(controlBox: ControlBox<Target>,
                     _ props: Props,
                     _ children: Children) {
    guard let box = controlBox as? ValueControlBox<Target> else { return }

    update(valueBox: box, props, children)
    box.value = props.value
    box.bind(valueChangedHandler: props.valueHandler)
  }
}
