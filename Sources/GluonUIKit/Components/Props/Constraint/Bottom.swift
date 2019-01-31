//
//  Bottom.swift
//  Gluon
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import Gluon
import UIKit

extension Bottom: YAxisConstraint {
  var firstAnchor: KeyPath<UIView, NSLayoutYAxisAnchor> {
    return \.bottomAnchor
  }

  var secondAnchor: KeyPath<UIView, NSLayoutYAxisAnchor> {
    return \.bottomAnchor
  }
}
