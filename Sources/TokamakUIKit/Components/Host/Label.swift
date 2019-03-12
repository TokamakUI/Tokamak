//
//  Label.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import Tokamak
import UIKit

final class TokamakLabel: UILabel, Default {
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

extension Label: UIViewComponent {
  public typealias RefTarget = UILabel

  static func update(view box: ViewBox<TokamakLabel>,
                     _ props: Label.Props,
                     _ children: [AnyNode]) {
    let view = box.view
    view.textAlignment = NSTextAlignment(props.alignment)
    view.numberOfLines = props.numberOfLines
    view.lineBreakMode = NSLineBreakMode(props.lineBreakMode)
    view.textColor = props.textColor.flatMap { UIColor($0) }
    view.text = props.text
  }
}
