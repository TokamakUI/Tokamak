//
//  Top.swift
//  Gluon
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import Gluon
import UIKit

extension Top: OffsetConstraint {
  var firstAnchor: KeyPath<UIView, NSLayoutDimension> {
    return \.topAnchor
  }

  var secondAnchor: KeyPath<UIView, NSLayoutDimension> {
    return \.topAnchor
  }
}
