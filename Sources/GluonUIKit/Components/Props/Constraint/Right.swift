//
//  Right.swift
//  Gluon
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import Gluon
import UIKit

extension Right: OffsetConstraint {
  var firstAnchor: KeyPath<UIView, NSLayoutDimension> {
    return \.rightAnchor
  }

  var secondAnchor: KeyPath<UIView, NSLayoutDimension> {
    return \.rightAnchor
  }
}
