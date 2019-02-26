//
//  Image.swift
//  TokamakUIKit
//
//  Created by Matvii Hodovaniuk on 2/17/19.
//

import Tokamak
import UIKit

final class TokamakImage: UIImageView, Default {
  public static var defaultValue: TokamakImage {
    return TokamakImage()
  }
}

extension UIImage.RenderingMode {
  public init(_ rawValue: ImageView.Props.RenderingMode) {
    switch rawValue {
    case .automatic:
      self = .automatic
    case .alwaysOriginal:
      self = .alwaysOriginal
    case .alwaysTemplate:
      self = .alwaysTemplate
    }
  }
}

extension ImageView: UIViewComponent {
  public typealias RefTarget = UIImageView

  static func update(
    view box: ViewBox<TokamakImage>,
    _ props: ImageView.Props,
    _ children: [AnyNode]
  ) {
    var image: UIImage?

    switch props.source {
    case let .name(name):
      image = UIImage(named: name)
    case let .data(data):
      image = UIImage(data: data, scale: CGFloat(props.scale))
    }

    if props.flipsForRTL {
      image = image?.imageFlippedForRightToLeftLayoutDirection()
    }

    box.view.image = image?.withRenderingMode(.init(props.renderingMode))
  }
}
