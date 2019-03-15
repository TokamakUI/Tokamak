//
//  Constraint.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 14/01/2019.
//

import Tokamak
import UIKit

extension UIView {
  func constraint(
    _ prop: Constraint,
    next: UIView?
  ) -> [NSLayoutConstraint] {
    switch prop {
    case let .height(height):
      return height.constraint(current: self, parent: superview, next: next)
    case let .width(width):
      return width.constraint(current: self, parent: superview, next: next)
    case let .bottom(location):
      return location.constraint(current: self, parent: superview, next: next)
    case let .top(location):
      return location.constraint(current: self, parent: superview, next: next)
    case let .centerX(location):
      return location.constraint(current: self, parent: superview, next: next)
    case let .centerY(location):
      return location.constraint(current: self, parent: superview, next: next)
    case let .center(location):
      return constraint(CenterX.equal(
        to: .external(location.target),
        constant: location.constant
      ), next: next) + constraint(CenterY.equal(
        to: .external(location.target),
        constant: location.constant
      ), next: next)
    case let .left(location):
      return location.constraint(current: self, parent: superview, next: next)
    case let .right(location):
      return location.constraint(current: self, parent: superview, next: next)
    case let .leading(location):
      return location.constraint(current: self, parent: superview, next: next)
    case let .trailing(location):
      return location.constraint(current: self, parent: superview, next: next)
    case let .edges(edges):
      let target = edges.target
      return constraint(Top.equal(
        to: target, constant: edges.insets.top
      ), next: next) +
        constraint(Bottom.equal(
          to: target, constant: -edges.insets.bottom
        ), next: next) +
        constraint(Left.equal(
          to: target, constant: edges.insets.left
        ), next: next) +
        constraint(Right.equal(
          to: target, constant: -edges.insets.right
        ), next: next)
    case let .firstBaseline(location):
      return location.constraint(current: self, parent: superview, next: next)
    case let .lastBaseline(location):
      return location.constraint(current: self, parent: superview, next: next)
    case let .size(size):
      switch size {
      case let .constant(constant):
        return constraint(
          Width.equal(to: .own, constant: constant.width), next: next
        ) + constraint(
          Height.equal(to: .own, constant: constant.height), next: next
        )
      case let .multiplier(target, multiplier):
        return constraint(
          Width.equal(to: .external(target), multiplier: multiplier),
          next: next
        ) + constraint(
          Height.equal(to: .external(target), multiplier: multiplier),
          next: next
        )
      }
    }
  }
}
