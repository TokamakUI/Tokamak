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

    public let style: Style?
    public let alwaysBounceHorizontal: Bool
    public let alwaysBounceVertical: Bool
    public let bounces: Bool
    public let bouncesZoom: Bool
    public let contentInset: ScrollOptions.EdgeInsets
    public let indicatorStyle: ScrollOptions.IndicatorStyle
    public let isDirectionalLockEnabled: Bool
    public let isPagingEnabled: Bool
    public let isScrollEnabled: Bool
    public let maximumZoomScale: Float
    public let minimumZoomScale: Float
    public let scrollIndicatorInsets: ScrollOptions.EdgeInsets
    public let scrollsToTop: Bool
    public let showsHorizontalScrollIndicator: Bool
    public let showsVerticalScrollIndicator: Bool
    public let zoomScale: Float
    public let scrollOptions: ScrollOptions

    public init(
      _ style: Style? = nil,
      alwaysBounceHorizontal: Bool = false,
      alwaysBounceVertical: Bool = false,
      bounces: Bool = true,
      bouncesZoom: Bool = true,
      contentInset: ScrollOptions.EdgeInsets = ScrollOptions.EdgeInsets(),
      indicatorStyle: ScrollOptions.IndicatorStyle = .default,
      isDirectionalLockEnabled: Bool = false,
      isPagingEnabled: Bool = false,
      isScrollEnabled: Bool = true,
      maximumZoomScale: Float = 1.0,
      minimumZoomScale: Float = 1.0,
      scrollIndicatorInsets: ScrollOptions.EdgeInsets = ScrollOptions.EdgeInsets(),
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
      scrollOptions = ScrollOptions(
        alwaysBounceHorizontal: alwaysBounceHorizontal,
        alwaysBounceVertical: alwaysBounceVertical,
        bounces: bounces,
        bouncesZoom: bouncesZoom,
        contentInset: contentInset,
        indicatorStyle: indicatorStyle,
        isDirectionalLockEnabled: isDirectionalLockEnabled,
        isPagingEnabled: isPagingEnabled,
        isScrollEnabled: isScrollEnabled,
        maximumZoomScale: maximumZoomScale,
        minimumZoomScale: minimumZoomScale,
        scrollIndicatorInsets: scrollIndicatorInsets,
        scrollsToTop: scrollsToTop,
        showsHorizontalScrollIndicator: showsHorizontalScrollIndicator,
        showsVerticalScrollIndicator: showsVerticalScrollIndicator,
        zoomScale: zoomScale
      )
    }
  }

  public typealias Children = AnyNode
}
