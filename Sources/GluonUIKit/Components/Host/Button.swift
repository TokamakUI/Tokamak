//
//  Button.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import Gluon
import UIKit

final class GluonButton: UIButton, Default {
  /// This property can't be defined in a `UIButton` extension
  /// as a plain `UIView` needs a different implementation of `defaultValue`
  /// and subclass extensions can't override extensions of a parent class.
  static var defaultValue: GluonButton {
    return GluonButton(type: .system)
  }
}

extension Button: UIControlComponent {
  typealias Target = GluonButton

  static func update(control box: ControlBox<GluonButton>,
                     _ props: Button.Props,
                     _ children: String) {
    let control = box.view

    if let titleColor = props.titleColor {
      control.setTitleColor(UIColor(titleColor), for: .normal)
    }

    control.setTitle(children, for: .normal)
  }
}
