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
  public static func update(_ view: UIButton,
                            _ props: ButtonProps,
                            _ children: String) {
    view.setTitleColor(UIColor(props.titleColor), for: .normal)
    view.setTitle(children, for: .normal)
  }
}
