//
//  Leading.swift
//  TokamakAppKit
//
//  Created by Matvii Hodovaniuk on 1/25/19.
//

import AppKit
import Tokamak

extension Leading: XAxisConstraint {
  var firstAnchor: KeyPath<Constrainable, NSLayoutXAxisAnchor> {
    return \.leadingAnchor
  }

  var secondAnchor: KeyPath<Constrainable, NSLayoutXAxisAnchor> {
    return \.leadingAnchor
  }
}
