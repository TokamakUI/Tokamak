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
  public init(_ rawValue: Image.RenderingMode) {
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
    box.view.contentMode = UIView.ContentMode(props.image.contentMode)
    box.view.image = UIImage.from(image: props.image)
  }
}
