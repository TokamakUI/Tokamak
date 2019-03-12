//
//  Right.swift
//  TokamakAppKit
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import AppKit
import Tokamak

extension Right: XAxisConstraint {
  var firstAnchor: KeyPath<Constrainable, NSLayoutXAxisAnchor> {
    return \.rightAnchor
  }

  var secondAnchor: KeyPath<Constrainable, NSLayoutXAxisAnchor> {
    return \.rightAnchor
  }
}
