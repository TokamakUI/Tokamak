//
//  Leading.swift
//  GluonUIKit
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import Gluon
import UIKit

extension Leading: OffsetConstraint {
  var firstAnchor: KeyPath<UIView, NSLayoutDimension> {
    return \.leadingAnchor
  }

  var secondAnchor: KeyPath<UIView, NSLayoutDimension> {
    return \.leadingAnchor
  }
}
