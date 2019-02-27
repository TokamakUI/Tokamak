//
//  Image.swift
//  Tokamak
//
//  Created by Max Desiatov on 26/02/2019.
//

import Tokamak
import UIKit

extension UIImage {
  static func from(image: Image) -> UIImage? {
    var result: UIImage?

    switch image.source {
    case let .name(name):
      result = UIImage(named: name)
    case let .data(data):
      result = UIImage(data: data, scale: CGFloat(image.scale))
    }

    if image.flipsForRTL {
      result = result?.imageFlippedForRightToLeftLayoutDirection()
    }

    return result
  }
}
