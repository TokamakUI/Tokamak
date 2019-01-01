//
//  Label.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import Gluon
import UIKit

final class GluonUILabel: UILabel, Default {
  static var defaultValue: GluonUILabel {
    return GluonUILabel()
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
  static func update(view box: ViewBox<GluonUILabel>,
                     _ props: Label.Props,
                     _ children: String) {
    let view = box.view
    view.textAlignment = NSTextAlignment(props.alignment)
    view.text = children
  }
}
