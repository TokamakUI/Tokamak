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
    public let bouncesZoom: Bool
    public let contentInset: EdgeInsets
    public let indicatorStyle: IndicatorStyle
    public let isDirectionalLockEnabled: Bool
    public let isPagingEnabled: Bool
    public let isScrollEnabled: Bool
    public let maximumZoomScale: Float
    public let minimumZoomScale: Float
    public let scrollIndicatorInsets: EdgeInsets
    public let scrollsToTop: Bool
    public let showsHorizontalScrollIndicator: Bool
    public let showsVerticalScrollIndicator: Bool
    public let zoomScale: Float

    public init(
      _ style: Style? = nil,
      alwaysBounceHorizontal: Bool = false,
      alwaysBounceVertical: Bool = false,
      bounces: Bool = true,
      bouncesZoom: Bool = true,
      contentInset: EdgeInsets = EdgeInsets(),
      indicatorStyle: IndicatorStyle = .default,
      isDirectionalLockEnabled: Bool = false,
      isPagingEnabled: Bool = false,
      isScrollEnabled: Bool = true,
      maximumZoomScale: Float = 1.0,
      minimumZoomScale: Float = 1.0,
      scrollIndicatorInsets: EdgeInsets = EdgeInsets(),
      scrollsToTop: Bool = true,
      showsHorizontalScrollIndicator: Bool = true,
      showsVerticalScrollIndicator: Bool = true,
      zoomScale: Float = 1.0
    ) {
      self.style = style
      self.alwaysBounceHorizontal = alwaysBounceHorizontal
      self.alwaysBounceVertical = alwaysBounceVertical
      self.bounces = bounces
      self.bouncesZoom = bouncesZoom
      self.contentInset = contentInset
      self.isDirectionalLockEnabled = isDirectionalLockEnabled
      self.isPagingEnabled = isPagingEnabled
      self.indicatorStyle = indicatorStyle
      self.isScrollEnabled = isScrollEnabled
      self.maximumZoomScale = maximumZoomScale
      self.minimumZoomScale = minimumZoomScale
      self.scrollIndicatorInsets = scrollIndicatorInsets
      self.scrollsToTop = scrollsToTop
      self.showsVerticalScrollIndicator = showsVerticalScrollIndicator
      self.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
      self.zoomScale = zoomScale
    }
  }

  public typealias Children = AnyNode
}
