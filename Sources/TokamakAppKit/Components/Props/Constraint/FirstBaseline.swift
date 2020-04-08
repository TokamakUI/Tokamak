//
//  FirstBaseline.swift
//  TokamakAppKit
//
//  Created by Max Desiatov on 03/02/2019.
//

import AppKit
import Tokamak

extension FirstBaseline: BaselineConstraint {
  var firstAnchor: KeyPath<NSView, NSLayoutYAxisAnchor> {
    \.firstBaselineAnchor
  }

  var secondAnchor: KeyPath<NSView, NSLayoutYAxisAnchor> {
    \.firstBaselineAnchor
  }
}
