//
//  Top.swift
//  TokamakUIKit
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import Tokamak
import UIKit

extension Top: YAxisConstraint {
  var firstAnchor: KeyPath<Constrainable, NSLayoutYAxisAnchor> {
    return \.topAnchor
  }

  var secondAnchor: KeyPath<Constrainable, NSLayoutYAxisAnchor> {
    return \.topAnchor
  }
}
