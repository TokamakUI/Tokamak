//
//  Image.swift
//  Gluon
//
//  Created by Matvii Hodovaniuk on 2/17/19.
//

import Gluon
import UIKit

final class GluonImage: UIImageView, Default {
  public static var defaultValue: GluonImage {
    return GluonImage()
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
  static func update(view box: ViewBox<GluonImage>, _ props: Image.Props, _ children: [AnyNode]) {
    let image: UIImage?

    switch props.source {
    case let .name(name):
      image = UIImage(named: name)
    case let .data(data):
      image = UIImage(data: data)
    }

    image.withRenderingMode(UIImage.RenderingMode(props.renderingMode))

    box.view.image = image
  }
}
