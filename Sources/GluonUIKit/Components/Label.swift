//
//  Label.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import Gluon
import UIKit

extension UILabel: Default {
  public static var defaultValue: UILabel {
    return UILabel()
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

extension Label: UIKitViewComponent {
  public static func update(_ view: UILabel,
                            _ props: Label.Props,
                            _ children: String) {
    view.textAlignment = NSTextAlignment(props.alignment)
    view.text = children
  }
}
