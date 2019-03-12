//
//  Label.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import AppKit
import Tokamak

final class TokamakLabel: NSTextView, Default {
  static var defaultValue: TokamakLabel {
    let result = TokamakLabel()
    result.isEditable = false
    result.backgroundColor = .clear
    return result
  }
}

extension NSTextAlignment {
  public init(_ alignment: TextAlignment) {
    switch alignment {
    case .left:
      self = .left
    case .right:
      self = .right
    case .center:
      self = .center
    case .justified:
      self = .justified
    case .natural:
      self = .natural
    }
  }
}

extension Label: NSViewComponent {
  public typealias RefTarget = NSTextView

  static func update(view box: ViewBox<TokamakLabel>,
                     _ props: Label.Props,
                     _ children: [AnyNode]) {
    let view = box.view
    view.alignment = NSTextAlignment(props.alignment)
    view.textContainer?.maximumNumberOfLines = props.numberOfLines
    view.textContainer?.lineBreakMode = NSLineBreakMode(props.lineBreakMode)
    if let textColor = props.textColor {
      view.textColor = NSColor(textColor)
    } else {
      view.textColor = .textColor
    }
    view.string = props.text
  }
}
