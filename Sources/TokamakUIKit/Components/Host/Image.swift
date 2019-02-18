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
  public init(_ rawValue: Image.Props.RenderingMode) {
    switch rawValue {
    case .automatic:
      self = UIImage.RenderingMode.automatic
    case .alwaysOriginal:
      self = UIImage.RenderingMode.alwaysOriginal
    case .alwaysTemplate:
      self = UIImage.RenderingMode.alwaysTemplate
    }
  }
}

extension Image: UIViewComponent {
  static func update(
    view box: ViewBox<TokamakImage>,
    _ props: Image.Props,
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
