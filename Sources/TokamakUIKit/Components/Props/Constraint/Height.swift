//
//  Height.swift
//  TokamakUIKit
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import Tokamak
import UIKit

extension Height: OwnConstraint {
  var firstAnchor: KeyPath<Constrainable, NSLayoutDimension> {
    return \.heightAnchor
  }

  var secondAnchor: KeyPath<Constrainable, NSLayoutDimension> {
    return \.heightAnchor
  }
}
