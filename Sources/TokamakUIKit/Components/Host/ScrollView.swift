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
    self.init(top: CGFloat(edges.top), left: CGFloat(edges.left), bottom: CGFloat(edges.bottom), right: CGFloat(edges.right))
  }
}

extension ScrollView: UIViewComponent {
  public typealias RefTarget = UIScrollView

  static func update(view box: ViewBox<TokamakScrollView>, _ props: ScrollView.Props, _ children: AnyNode) {
    let view = box.view
    view.contentInset = UIEdgeInsets(props.contentInset)
    view.bounces = props.bounces
    view.scrollsToTop = props.scrollsToTop
  }
}
