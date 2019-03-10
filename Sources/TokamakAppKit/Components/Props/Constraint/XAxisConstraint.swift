//
//  XAxisConstraint.swift
//  TokamakAppKit
//
//  Created by Max Desiatov on 17/01/2019.
//

import AppKit
import Tokamak

protocol XAxisConstraint {
  var firstAnchor: KeyPath<Constrainable, NSLayoutXAxisAnchor> { get }
  var secondAnchor: KeyPath<Constrainable, NSLayoutXAxisAnchor> { get }
  var target: Constraint.SafeAreaTarget { get }
  var constant: Double { get }
}

extension XAxisConstraint {
  func constraint(
    current: NSView,
    parent: NSView?,
    next: NSView?
  ) -> [NSLayoutConstraint] {
    let secondView: Constrainable?
    switch target {
    case .external(.next):
      secondView = next
    case .external(.parent), .safeArea:
      secondView = parent
    }

    guard let second = secondView?[keyPath: secondAnchor] else { return [] }

    return [current[keyPath: firstAnchor].constraint(
      equalTo: second,
      constant: CGFloat(constant)
    )]
  }
}
