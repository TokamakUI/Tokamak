//
//  FirstBaseline.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 03/02/2019.
//

import Gluon
import UIKit

extension FirstBaseline: BaselineConstraint {
  var firstAnchor: KeyPath<UIView, NSLayoutYAxisAnchor> {
    return \.firstBaselineAnchor
  }

  var secondAnchor: KeyPath<UIView, NSLayoutYAxisAnchor> {
    return \.firstBaselineAnchor
  }
}
