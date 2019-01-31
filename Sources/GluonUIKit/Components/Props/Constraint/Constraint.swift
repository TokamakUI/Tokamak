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
      return height.constraint(
        current: self,
        parent: superview,
        next: next
      )
    case let .width(width):
      return width.constraint(
        current: self,
        parent: superview,
        next: next
      )
    case .baseline:
      fatalError()
    case let .bottom(location):
      let target: UIView?
      switch location.target {
      case .next:
        target = next
      case .parent:
        target = superview
      }

      guard let secondAnchor = target?.bottomAnchor else { return [] }

      return [bottomAnchor.constraint(equalTo: secondAnchor)]
    case let .top(location):
      let target: UIView?
      switch location.target {
      case .next:
        target = next
      case .parent:
        target = superview
      }

      guard let secondAnchor = target?.topAnchor else { return [] }

      return [topAnchor.constraint(equalTo: secondAnchor)]
    case .center:
      fatalError()
    case .centerX:
      fatalError()
    case .centerY:
      fatalError()
    case let .left(location):
      let target: UIView?
      switch location.target {
      case .next:
        target = next
      case .parent:
        target = superview
      }

      guard let secondAnchor = target?.leftAnchor else { return [] }

      return [leftAnchor.constraint(equalTo: secondAnchor)]
    case let .right(location):
      let target: UIView?
      switch location.target {
      case .next:
        target = next
      case .parent:
        target = superview
      }

      guard let secondAnchor = target?.rightAnchor else { return [] }

      return [rightAnchor.constraint(equalTo: secondAnchor)]
    case let .leading(location):
      let target: UIView?
      switch location.target {
      case .next:
        target = next
      case .parent:
        target = superview
      }

      guard let secondAnchor = target?.leadingAnchor else { return [] }

      return [leadingAnchor.constraint(equalTo: secondAnchor)]
    case let .trailing(location):
      let target: UIView?
      switch location.target {
      case .next:
        target = next
      case .parent:
        target = superview
      }

      guard let secondAnchor = target?.trailingAnchor else { return [] }

      return [trailingAnchor.constraint(equalTo: secondAnchor)]
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
      fatalError()
    case .lastBaseline:
      fatalError()
    }
  }
}
