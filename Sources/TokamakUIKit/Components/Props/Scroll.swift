//
//  Scroll.swift
//  TokamakUIKit
//
//  Created by Matvii Hodovaniuk on 3/27/19.
//

import Tokamak
import UIKit

func applyScrollOptions<T: UIScrollView>(
  _ box: ViewBox<T>,
  _ props: ScrollView.Props
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
