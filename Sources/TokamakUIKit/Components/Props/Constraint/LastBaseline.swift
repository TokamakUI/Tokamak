//
//  LastBaseline.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 03/02/2019.
//

import Tokamak
import UIKit

extension LastBaseline: BaselineConstraint {
  var firstAnchor: KeyPath<UIView, NSLayoutYAxisAnchor> {
    return \.lastBaselineAnchor
  }

  var secondAnchor: KeyPath<UIView, NSLayoutYAxisAnchor> {
    return \.lastBaselineAnchor
  }
}
