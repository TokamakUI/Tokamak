//
//  FirstBaseline.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 03/02/2019.
//

import Tokamak
import UIKit

extension FirstBaseline: BaselineConstraint {
  var firstAnchor: KeyPath<UIView, NSLayoutYAxisAnchor> {
    return \.firstBaselineAnchor
  }

  var secondAnchor: KeyPath<UIView, NSLayoutYAxisAnchor> {
    return \.firstBaselineAnchor
  }
}
