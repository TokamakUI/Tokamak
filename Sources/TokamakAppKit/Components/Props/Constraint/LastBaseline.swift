//
//  LastBaseline.swift
//  TokamakAppKit
//
//  Created by Max Desiatov on 03/02/2019.
//

import AppKit
import Tokamak

extension LastBaseline: BaselineConstraint {
  var firstAnchor: KeyPath<NSView, NSLayoutYAxisAnchor> {
    return \.lastBaselineAnchor
  }

  var secondAnchor: KeyPath<NSView, NSLayoutYAxisAnchor> {
    return \.lastBaselineAnchor
  }
}
