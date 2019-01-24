//
//  StackView.swift
//  Gluon
//
//  Created by Max Desiatov on 02/12/2018.
//

public struct StackView: HostComponent {
  public struct Props: Equatable, StyleProps, Default {
    public static var defaultValue: Props {
      return Props()
    }

    public enum Alignment {
      case fill
      case center
      case leading
      case trailing
      case top
      case bottom
    }

    public enum Axis {
      case horizontal
      case vertical
    }

    public enum Distribution {
      case fill
      case fillEqually
      case fillProportionally
      case equalSpacing
    }

    public let alignment: Alignment
    public let axis: Axis
    public let distribution: Distribution
    public let style: Style?
    public let spacing: Double

    public init(alignment: Alignment = .fill,
                axis: Axis = .horizontal,
                distribution: Distribution = .fill,
                spacing: Double = 0,
                _ style: Style? = nil) {
      self.alignment = alignment
      self.axis = axis
      self.distribution = distribution
      self.style = style
      self.spacing = spacing
    }
  }

  public typealias Children = [AnyNode]
}
