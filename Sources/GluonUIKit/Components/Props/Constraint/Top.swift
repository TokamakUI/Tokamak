//
//  Top.swift
//  Gluon
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import Gluon
import UIKit

extension Top: YAxisConstraint {
  var firstAnchor: KeyPath<UIView, NSLayoutYAxisAnchor> {
    return \.topAnchor
  }

  var secondAnchor: KeyPath<UIView, NSLayoutYAxisAnchor> {
    return \.topAnchor
  }
}
