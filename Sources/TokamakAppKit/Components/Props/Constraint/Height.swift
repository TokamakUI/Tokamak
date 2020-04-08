//
//  Height.swift
//  TokamakAppKit
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import AppKit
import Tokamak

extension Height: OwnConstraint {
  var firstAnchor: KeyPath<Constrainable, NSLayoutDimension> {
    \.heightAnchor
  }

  var secondAnchor: KeyPath<Constrainable, NSLayoutDimension> {
    \.heightAnchor
  }
}
