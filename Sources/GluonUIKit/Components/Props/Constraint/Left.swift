//
//  Left.swift
//  Gluon
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import Gluon
import UIKit

extension Left: XAxisConstraint {
  var firstAnchor: KeyPath<UIView, NSLayoutXAxisAnchor> {
    return \.leftAnchor
  }

  var secondAnchor: KeyPath<UIView, NSLayoutXAxisAnchor> {
    return \.leftAnchor
  }
}
