//
//  Bottom.swift
//  Gluon
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import Gluon
import UIKit

extension Bottom: OffsetConstraint {
  var firstAnchor: KeyPath<UIView, NSLayoutDimension> {
    return \.bottomAnchor
  }

  var secondAnchor: KeyPath<UIView, NSLayoutDimension> {
    return \.bottomAnchor
  }
}
