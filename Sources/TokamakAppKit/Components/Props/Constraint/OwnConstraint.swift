//
//  OwnConstraint.swift
//  TokamakAppKit
//
//  Created by Max Desiatov on 02/02/2019.
//

import AppKit
import Tokamak

protocol OwnConstraint {
  var firstAnchor: KeyPath<Constrainable, NSLayoutDimension> { get }
  var secondAnchor: KeyPath<Constrainable, NSLayoutDimension> { get }
  var target: Constraint.OwnTarget { get }
  var constant: Double { get }
  var multiplier: Double { get }
}

extension OwnConstraint {
  func constraint(
    current: NSView,
    parent: NSView?,
    next: NSView?
  ) -> [NSLayoutConstraint] {
    switch target {
    case .own:
      return [current[keyPath: firstAnchor].constraint(
        equalToConstant: CGFloat(constant)
      )]
    case let .external(target):
      let secondView: Constrainable?
      switch target {
      case .next:
        secondView = next
      case .parent:
        secondView = parent
      }

      guard let second = secondView?[keyPath: secondAnchor] else { return [] }

      return [current[keyPath: firstAnchor].constraint(
        equalTo: second,
        multiplier: CGFloat(multiplier),
        constant: CGFloat(constant)
      )]
    }
  }
}
