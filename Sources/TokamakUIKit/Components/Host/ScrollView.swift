//
//  ScrollView.swift
//  TokamakUIKit
//
//  Created by Matvii Hodovaniuk on 2/28/19.
//

import Tokamak
import UIKit

final class TokamakScrollView: UIScrollView, Default {
  static var defaultValue: TokamakScrollView {
    return TokamakScrollView()
  }
}

extension UIEdgeInsets {
  public init(_ edges: ScrollView.Props.EdgeInsets) {
    self.init(
      top: CGFloat(edges.top),
      left: CGFloat(edges.left),
      bottom: CGFloat(edges.bottom),
      right: CGFloat(edges.right)
    )
  }
}

extension UIScrollView.IndicatorStyle {
  public init(_ type: ScrollView.Props.IndicatorStyle) {
    switch type {
    case .default:
      self = .default
    case .black:
      self = .black
    case .white:
      self = .white
    }
  }
}

extension ScrollView: UIViewComponent {
  public typealias RefTarget = UIScrollView

  static func update(
    view box: ViewBox<TokamakScrollView>,
    _ props: ScrollView.Props,
    _ children: AnyNode
  ) {
    let view = box.view
    view.alwaysBounceHorizontal = props.alwaysBounceHorizontal
    view.alwaysBounceVertical = props.alwaysBounceVertical
    view.bounces = props.bounces
    view.bouncesZoom = props.bouncesZoom
    view.contentInset = UIEdgeInsets(props.contentInset)
    view.isDirectionalLockEnabled = props.isDirectionalLockEnabled
    view.isPagingEnabled = props.isPagingEnabled
    view.indicatorStyle = UIScrollView.IndicatorStyle(props.indicatorStyle)
    view.isScrollEnabled = props.isScrollEnabled
    view.maximumZoomScale = CGFloat(props.maximumZoomScale)
    view.minimumZoomScale = CGFloat(props.minimumZoomScale)
    view.scrollIndicatorInsets = UIEdgeInsets(props.scrollIndicatorInsets)
    view.scrollsToTop = props.scrollsToTop
    view.showsVerticalScrollIndicator = props.showsVerticalScrollIndicator
    view.showsHorizontalScrollIndicator = props.showsHorizontalScrollIndicator
    view.zoomScale = CGFloat(props.zoomScale)
  }
}
