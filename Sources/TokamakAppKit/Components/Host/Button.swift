//
//  Button.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import AppKit
import Tokamak

final class TokamakButton: NSButton, Default {
  /// This property can't be defined in a `UIButton` extension
  /// as a plain `UIView` needs a different implementation of `defaultValue`
  /// and subclass extensions can't override extensions of a parent class.
  static var defaultValue: TokamakButton {
    let result = TokamakButton()
    result.bezelStyle = .rounded
    return result
  }
}

extension Button: NSControlComponent {
  typealias Target = TokamakButton
  public typealias RefTarget = NSButton

  static func update(control box: ControlBox<TokamakButton>,
                     _ props: Button.Props,
                     _ children: [AnyNode]) {
    let control = box.view

    control.contentTintColor = props.titleColor.flatMap { NSColor($0) }

    control.title = props.text
  }
}
