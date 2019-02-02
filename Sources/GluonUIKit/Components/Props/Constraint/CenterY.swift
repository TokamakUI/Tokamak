//
//  CenterY.swift
//  GluonUIKit
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import Gluon
import UIKit

extension CenterY: YAxisConstraint {
  var firstAnchor: KeyPath<Constrainable, NSLayoutYAxisAnchor> {
    return \.centerYAnchor
  }

  var secondAnchor: KeyPath<Constrainable, NSLayoutYAxisAnchor> {
    return \.centerYAnchor
  }
}
