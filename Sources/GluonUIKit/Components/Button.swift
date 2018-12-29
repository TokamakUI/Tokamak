//
//  Button.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import Gluon
import UIKit

extension UIButton: Default {}

extension Button: UIKitControlComponent {
  public typealias Target = UIButton

  public static func update(wrapper: ControlWrapper<UIButton>,
                            _ props: ButtonProps,
                            _ children: String) {
    let control = wrapper.control

    control.setTitleColor(UIColor(props.titleColor), for: .normal)
    control.setTitle(children, for: .normal)
  }
}
