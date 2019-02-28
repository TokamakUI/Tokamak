//
//  ScrollView.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 2/28/19.
//

public struct ScrollView: HostComponent {
  public struct Props: Equatable, StyleProps, Default {
    public static var defaultValue: Props {
      return Props()
    }

//        /// not exposing style: UIScrollView is a non-rendering subclass of UIView
//        /// https://useyourloaf.com/blog/stack-view-background-color/
    public let style: Style?

    public init(
      _ frame: Rectangle
    ) {
      style = Style(frame)
    }

    public init(
      _ constraint: Constraint
    ) {
      style = Style(constraint)
    }

    public init(
      _ constraints: [Constraint]
    ) {
      style = Style(constraints)
    }

    public init(
    ) {
      style = nil
    }
  }

  public typealias Children = [AnyNode]
}
