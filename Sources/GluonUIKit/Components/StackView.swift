//
//  StackView.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import Gluon
import UIKit

extension UIStackView: Default {
  public static var defaultValue: UIStackView {
    return UIStackView()
  }
}

extension UIStackView.Alignment {
  public init(_ alignment: StackViewProps.Alignment) {
    switch alignment {
    case .top:
      self = .top
    case .bottom:
      self = .bottom
    case .leading:
      self = .leading
    case .trailing:
      self = .trailing
    case .center:
      self = .center
    case .fill:
      self = .fill
    }
  }
}

extension NSLayoutConstraint.Axis {
  public init(_ axis: StackViewProps.Axis) {
    switch axis {
    case .horizontal:
      self = .horizontal
    case .vertical:
      self = .vertical
    }
  }
}

extension UIStackView.Distribution {
  public init(_ distribution: StackViewProps.Distribution) {
    switch distribution {
    case .fill:
      self = .fill
    case .fillEqually:
      self = .fillEqually
    case .fillProportionally:
      self = .fillProportionally
    case .equalSpacing:
      self = .equalSpacing
    }
  }
}

extension StackView: UIKitViewComponent {
  public static func update(_ view: UIStackView,
                            _ props: StackViewProps,
                            _: [Node]) {
    view.alignment = UIStackView.Alignment(props.alignment)
    view.axis = NSLayoutConstraint.Axis(props.axis)
    view.distribution = UIStackView.Distribution(props.distribution)
    view.frame = CGRect(props.frame)
  }
}
