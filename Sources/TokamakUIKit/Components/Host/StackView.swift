//
//  StackView.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import Tokamak
import UIKit

final class TokamakStackView: UIStackView, Default {
  static var defaultValue: TokamakStackView {
    return TokamakStackView()
  }
}

extension UIStackView.Alignment {
  public init(_ alignment: StackView.Props.Alignment) {
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
  public init(_ axis: StackView.Props.Axis) {
    switch axis {
    case .horizontal:
      self = .horizontal
    case .vertical:
      self = .vertical
    }
  }
}

extension UIStackView.Distribution {
  public init(_ distribution: StackView.Props.Distribution) {
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

extension StackView: UIViewComponent {
  public typealias RefTarget = UIStackView

  static func update(view box: ViewBox<TokamakStackView>,
                     _ props: StackView.Props,
                     _: [AnyNode]) {
    let view = box.view
    view.alignment = UIStackView.Alignment(props.alignment)
    view.axis = NSLayoutConstraint.Axis(props.axis)
    view.distribution = UIStackView.Distribution(props.distribution)
    view.spacing = CGFloat(props.spacing)
  }
}
