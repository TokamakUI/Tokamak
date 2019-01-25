//
//  Width.swift
//  Gluon
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import Gluon
import UIKit

extension Width: OffsetConstraint {
  var firstAnchor: KeyPath<UIView, NSLayoutDimension> {
    return \.widthAnchor
  }

  var secondAnchor: KeyPath<UIView, NSLayoutDimension> {
    return \.widthAnchor
  }
}
