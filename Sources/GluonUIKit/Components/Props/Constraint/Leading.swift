//
//  Leading.swift
//  GluonUIKit
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import Gluon
import UIKit

extension Leading: XAxisConstraint {
  var firstAnchor: KeyPath<UIView, NSLayoutXAxisAnchor> {
    return \.leadingAnchor
  }

  var secondAnchor: KeyPath<UIView, NSLayoutXAxisAnchor> {
    return \.leadingAnchor
  }
}
