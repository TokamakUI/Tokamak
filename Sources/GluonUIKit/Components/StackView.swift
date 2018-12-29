//
//  StackView.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import Gluon
import UIKit

extension UIStackView: Default {}

extension StackViewProps.Axis {
  var value: NSLayoutConstraint.Axis {
    switch self {
    case .horizontal:
      return .horizontal
    case .vertical:
      return .vertical
    }
  }
}

extension StackViewProps.Distribution {
  var value: UIStackView.Distribution {
    switch self {
    case .fill:
      return .fill
    case .fillEqually:
      return .fillEqually
    case .fillProportionally:
      return .fillProportionally
    case .equalSpacing:
      return .equalSpacing
    }
  }
}

extension StackView: UIKitViewComponent {
  public static func update(_ view: UIStackView,
                            _ props: StackViewProps,
                            _: [Node]) {
    view.axis = props.axis.value
    view.distribution = props.distribution.value
    view.frame = CGRect(props.frame)
  }
}
