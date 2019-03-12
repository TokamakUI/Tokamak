//
//  BaselineConstraint.swift
//  TokamakAppKit
//
//  Created by Max Desiatov on 03/02/2019.
//

import AppKit
import Tokamak

protocol BaselineConstraint {
  var firstAnchor: KeyPath<NSView, NSLayoutYAxisAnchor> { get }
  var secondAnchor: KeyPath<NSView, NSLayoutYAxisAnchor> { get }
  var target: Constraint.Target { get }
  var constant: Double { get }
}

extension BaselineConstraint {
  func constraint(
    current: NSView,
    parent: NSView?,
    next: NSView?
  ) -> [NSLayoutConstraint] {
    let secondView: NSView?
    switch target {
    case .next:
      secondView = next
    case .parent:
      secondView = parent
    }

    guard let second = secondView?[keyPath: secondAnchor] else { return [] }

    return [current[keyPath: firstAnchor].constraint(
      equalTo: second,
      constant: CGFloat(constant)
    )]
  }
}
