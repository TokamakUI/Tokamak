//
//  Constraint.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 14/01/2019.
//

import Gluon
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
    case .center:
      fatalError()
    case let .centerX(location):
      return location.constraint(current: self, parent: superview, next: next)
    case let .centerY(location):
      return location.constraint(current: self, parent: superview, next: next)
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
          to: target, constant: edges.insets.bottom
        ), next: next) +
        constraint(Left.equal(
          to: target, constant: edges.insets.left
        ), next: next) +
        constraint(Right.equal(
          to: target, constant: edges.insets.right
        ), next: next)
    case .firstBaseline:
      // FIXME:
      fatalError()
    case .lastBaseline:
      // FIXME:
      fatalError()
    case .size:
      // FIXME:
      fatalError()
    }
  }
}
