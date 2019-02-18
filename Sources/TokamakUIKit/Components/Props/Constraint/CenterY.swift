//
//  CenterY.swift
//  TokamakUIKit
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import Tokamak
import UIKit

extension CenterY: YAxisConstraint {
  var firstAnchor: KeyPath<Constrainable, NSLayoutYAxisAnchor> {
    return \.centerYAnchor
  }

  var secondAnchor: KeyPath<Constrainable, NSLayoutYAxisAnchor> {
    return \.centerYAnchor
  }
}
