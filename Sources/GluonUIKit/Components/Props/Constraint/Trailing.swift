//
//  Trailing.swift
//  GluonUIKit
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import Gluon
import UIKit

extension Trailing: OffsetConstraint {
  var firstAnchor: KeyPath<UIView, NSLayoutDimension> {
    return \.trailingAnchor
  }

  var secondAnchor: KeyPath<UIView, NSLayoutDimension> {
    return \.trailingAnchor
  }
}
