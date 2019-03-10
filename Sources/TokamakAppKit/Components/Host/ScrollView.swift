//
//  ScrollView.swift
//  TokamakUIKit
//
//  Created by Matvii Hodovaniuk on 2/28/19.
//

import AppKit
import Tokamak

final class TokamakScrollView: NSScrollView, Default {
  static var defaultValue: TokamakScrollView {
    return TokamakScrollView()
  }
}

extension NSEdgeInsets {
  public init(_ edges: ScrollView.Props.EdgeInsets) {
    self.init(
      top: CGFloat(edges.top),
      left: CGFloat(edges.left),
      bottom: CGFloat(edges.bottom),
      right: CGFloat(edges.right)
    )
  }
}

extension ScrollView: NSViewComponent {
  public typealias RefTarget = NSScrollView

  static func update(
    view box: ViewBox<TokamakScrollView>,
    _ props: ScrollView.Props,
    _ children: AnyNode
  ) {
    // FIXME:
//    let view = box.view
//    view.alwaysBounceHorizontal = props.alwaysBounceHorizontal
//    view.alwaysBounceVertical = props.alwaysBounceVertical
//    view.bounces = props.bounces
//    view.bouncesZoom = props.bouncesZoom
//    view.contentInset = UIEdgeInsets(props.contentInset)
//    view.isDirectionalLockEnabled = props.isDirectionalLockEnabled
//    view.isPagingEnabled = props.isPagingEnabled
//    view.indicatorStyle = UIScrollView.IndicatorStyle(props.indicatorStyle)
//    view.isScrollEnabled = props.isScrollEnabled
//    view.maximumZoomScale = CGFloat(props.maximumZoomScale)
//    view.minimumZoomScale = CGFloat(props.minimumZoomScale)
//    view.scrollIndicatorInsets = UIEdgeInsets(props.scrollIndicatorInsets)
//    view.scrollsToTop = props.scrollsToTop
//    view.showsVerticalScrollIndicator = props.showsVerticalScrollIndicator
//    view.showsHorizontalScrollIndicator = props.showsHorizontalScrollIndicator
//    view.zoomScale = CGFloat(props.zoomScale)
  }
}
