//
//  Left.swift
//  Gluon
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import Gluon
import UIKit

extension Left: OffsetConstraint {
  var firstAnchor: KeyPath<UIView, NSLayoutDimension> {
    return \.leftAnchor
  }

  var secondAnchor: KeyPath<UIView, NSLayoutDimension> {
    return \.leftAnchor
  }
}
