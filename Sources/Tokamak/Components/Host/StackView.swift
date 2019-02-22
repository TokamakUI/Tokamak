//
//  StackView.swift
//  Tokamak
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
    public let spacing: Double

    /// not exposing style: UIStackView is a non-rendering subclass of UIView
    /// https://useyourloaf.com/blog/stack-view-background-color/
    public let style: Style?

    public init(
      _ frame: Rectangle,
      alignment: Alignment = .fill,
      axis: Axis = .horizontal,
      distribution: Distribution = .fill,
      spacing: Double = 0
    ) {
      self.alignment = alignment
      self.axis = axis
      self.distribution = distribution
      style = Style(frame)
      self.spacing = spacing
    }

    public init(
      _ constraint: Constraint,
      alignment: Alignment = .fill,
      axis: Axis = .horizontal,
      distribution: Distribution = .fill,
      spacing: Double = 0
    ) {
      self.alignment = alignment
      self.axis = axis
      self.distribution = distribution
      style = Style(constraint)
      self.spacing = spacing
    }

    public init(
      _ constraints: [Constraint],
      alignment: Alignment = .fill,
      axis: Axis = .horizontal,
      distribution: Distribution = .fill,
      spacing: Double = 0
    ) {
      self.alignment = alignment
      self.axis = axis
      self.distribution = distribution
      style = Style(constraints)
      self.spacing = spacing
    }

    public init(
      alignment: Alignment = .fill,
      axis: Axis = .horizontal,
      distribution: Distribution = .fill,
      spacing: Double = 0
    ) {
      self.alignment = alignment
      self.axis = axis
      self.distribution = distribution
      style = nil
      self.spacing = spacing
    }
  }

  public typealias Children = [AnyNode]
}
