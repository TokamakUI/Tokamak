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

    public struct EdgeInsets: Equatable {
      public let bottom: Float
      public let left: Float
      public let right: Float
      public let top: Float

      public init(
        top: Float = 0,
        left: Float = 0,
        bottom: Float = 0,
        right: Float = 0
      ) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
      }
    }

    public enum IndicatorStyle {
      case `default`
      case black
      case white
    }

    public let style: Style?
    public let alwaysBounceHorizontal: Bool
    public let alwaysBounceVertical: Bool
    public let bounces: Bool
    public let contentInset: EdgeInsets
    public let indicatorStyle: IndicatorStyle
    public let scrollsToTop: Bool

    public init(
      _ style: Style? = nil,
      alwaysBounceHorizontal: Bool = false,
      alwaysBounceVertical: Bool = false,
      bounces: Bool = true,
      contentInset: EdgeInsets = EdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
      indicatorStyle: IndicatorStyle = .default,
      scrollsToTop: Bool = true
    ) {
      self.style = style
      self.alwaysBounceHorizontal = alwaysBounceHorizontal
      self.alwaysBounceVertical = alwaysBounceVertical
      self.bounces = bounces
      self.contentInset = contentInset
      self.indicatorStyle = indicatorStyle
      self.scrollsToTop = scrollsToTop
    }
  }

  public typealias Children = AnyNode
}
