//
//  StackView.swift
//  Gluon
//
//  Created by Max Desiatov on 02/12/2018.
//

import Gluon
import UIKit

public struct StackViewProps: Equatable {
  public enum Axis: Equatable {
    case horizontal
    case vertical
  }

  public enum Distribution: Equatable {
    case fill
    case fillEqually
    case fillProportionally
    case equalSpacing
  }

  public let axis: Axis
  public let distribution: Distribution
  public let frame: CGRect

  public init(axis: Axis = .horizontal,
              distribution: Distribution = .fill,
              frame: CGRect) {
    self.axis = axis
    self.distribution = distribution
    self.frame = frame
  }
}

public struct StackView: HostComponent {
  public typealias Props = StackViewProps
  public typealias Children = [Node]
}

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
    view.frame = props.frame
  }
}
