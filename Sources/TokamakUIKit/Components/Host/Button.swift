//
//  Button.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import Tokamak
import UIKit

final class TokamakButton: UIButton, Default {
  /// This property can't be defined in a `UIButton` extension
  /// as a plain `UIView` needs a different implementation of `defaultValue`
  /// and subclass extensions can't override extensions of a parent class.
  static var defaultValue: TokamakButton {
    return TokamakButton(type: .system)
  }
}

extension Button: UIControlComponent {
  typealias Target = TokamakButton
  public typealias RefTarget = UIButton

  static func update(control box: ControlBox<TokamakButton>,
                     _ props: Button.Props,
                     _ children: [AnyNode]) {
    let control = box.view

    if let titleColor = props.titleColor {
      control.setTitleColor(UIColor(titleColor), for: .normal)
    }

    control.setTitle(props.text, for: .normal)
  }
}
