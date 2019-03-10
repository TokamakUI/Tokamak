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
    return TokamakLabel()
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
                     _ children: String) {
    let view = box.view
    view.alignment = NSTextAlignment(props.alignment)
    view.textContainer?.maximumNumberOfLines = props.numberOfLines
    view.textContainer?.lineBreakMode = NSLineBreakMode(props.lineBreakMode)
    view.textColor = props.textColor.flatMap { NSColor($0) }
    view.string = children
  }
}
