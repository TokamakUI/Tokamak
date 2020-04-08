//
//  ScrollView.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 2/28/19.
//

public struct ScrollView: HostComponent {
  public struct Props: Equatable, StyleProps, Default {
    public static var defaultValue: Props {
      Props()
    }

    public let style: Style?
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
