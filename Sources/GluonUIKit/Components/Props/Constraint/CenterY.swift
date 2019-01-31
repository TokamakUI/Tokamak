//
//  CenterY.swift
//  GluonUIKit
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import Gluon
import UIKit

extension CenterY: OffsetConstraint {
  var firstAnchor: KeyPath<UIView, NSLayoutDimension> {
    return \.centerYAnchor
  }

  var secondAnchor: KeyPath<UIView, NSLayoutDimension> {
    return \.centerYAnchor
  }
}
