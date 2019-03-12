//
//  CenterY.swift
//  TokamakAppKit
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import AppKit
import Tokamak

extension CenterY: YAxisConstraint {
  var firstAnchor: KeyPath<Constrainable, NSLayoutYAxisAnchor> {
    return \.centerYAnchor
  }

  var secondAnchor: KeyPath<Constrainable, NSLayoutYAxisAnchor> {
    return \.centerYAnchor
  }
}
