//
//  Height.swift
//  GluonUIKit
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import Gluon
import UIKit

extension Height: OwnConstraint {
  var firstAnchor: KeyPath<UIView, NSLayoutDimension> {
    return \.heightAnchor
  }

  var secondAnchor: KeyPath<UIView, NSLayoutDimension> {
    return \.heightAnchor
  }
}
