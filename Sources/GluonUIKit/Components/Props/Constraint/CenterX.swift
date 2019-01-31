//
//  CenterX.swift
//  GluonUIKit
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import Gluon
import UIKit

extension CenterX: XAxisConstraint {
  var firstAnchor: KeyPath<UIView, NSLayoutXAxisAnchor> {
    return \.centerXAnchor
  }

  var secondAnchor: KeyPath<UIView, NSLayoutXAxisAnchor> {
    return \.centerXAnchor
  }
}
