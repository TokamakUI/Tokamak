//
//  StackView.swift
//  Gluon
//
//  Created by Max Desiatov on 02/12/2018.
//

public struct StackView: HostComponent {
  public struct Props: Equatable, StyleProps {
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
    public let frame: Rectangle
    public let style: Style?

    public init(alignment: Alignment = .fill,
                axis: Axis = .horizontal,
                distribution: Distribution = .fill,
                frame: Rectangle,
                style: Style? = nil) {
      self.alignment = alignment
      self.axis = axis
      self.distribution = distribution
      self.frame = frame
      self.style = style
    }
  }

  public typealias Children = [AnyNode]
}
