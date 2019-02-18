//
//  Bottom.swift
//  TokamakUIKit
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import Tokamak
import UIKit

extension Bottom: YAxisConstraint {
  var firstAnchor: KeyPath<Constrainable, NSLayoutYAxisAnchor> {
    return \.bottomAnchor
  }

  var secondAnchor: KeyPath<Constrainable, NSLayoutYAxisAnchor> {
    return \.bottomAnchor
  }
}
