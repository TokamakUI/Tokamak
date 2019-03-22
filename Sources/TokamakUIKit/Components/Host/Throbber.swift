//
//  Throbber.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 20/03/2019.
//

import Tokamak
import UIKit

extension UIActivityIndicatorView.Style {
  init(_ variety: Throbber.Props.Variety) {
    switch variety {
    case .gray:
      self = .gray
    case .white:
      self = .white
    case .whiteLarge:
      self = .whiteLarge
    }
  }
}

final class TokamakActivityIndicatorView: UIActivityIndicatorView, Default {
  public static var defaultValue: TokamakActivityIndicatorView {
    return TokamakActivityIndicatorView()
  }
}

extension Throbber: UIViewComponent {
  public typealias RefTarget = UIActivityIndicatorView

  static func update(view box: ViewBox<TokamakActivityIndicatorView>,
                     _ props: Throbber.Props,
                     _: Null) {
    let view = box.view

    view.style = UIActivityIndicatorView.Style(props.variety)
    view.color = props.color.flatMap { UIColor($0) }
    view.hidesWhenStopped = props.hidesWhenStopped

    switch (view.isAnimating, props.isAnimating) {
    case (true, false):
      view.stopAnimating()
    case (false, true):
      view.startAnimating()
    default:
      ()
    }
  }
}
