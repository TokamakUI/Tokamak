//
//  Right.swift
//  Gluon
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import Gluon
import UIKit

extension Right: XAxisConstraint {
  var firstAnchor: KeyPath<UIView, NSLayoutXAxisAnchor> {
    return \.rightAnchor
  }

  var secondAnchor: KeyPath<UIView, NSLayoutXAxisAnchor> {
    return \.rightAnchor
  }
}
