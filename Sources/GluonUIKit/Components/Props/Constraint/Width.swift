//
//  Width.swift
//  Gluon
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import Gluon
import UIKit

extension Width: OwnConstraint {
  var firstAnchor: KeyPath<Constrainable, NSLayoutDimension> {
    return \.widthAnchor
  }

  var secondAnchor: KeyPath<Constrainable, NSLayoutDimension> {
    return \.widthAnchor
  }
}
