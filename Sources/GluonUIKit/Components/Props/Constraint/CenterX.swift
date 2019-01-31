//
//  CenterX.swift
//  GluonUIKit
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import Gluon
import UIKit

extension CenterX: OffsetConstraint {
  var firstAnchor: KeyPath<UIView, NSLayoutDimension> {
    return \.centerXAnchor
  }
  
  var secondAnchor: KeyPath<UIView, NSLayoutDimension> {
    return \.centerXAnchor
  }
}

