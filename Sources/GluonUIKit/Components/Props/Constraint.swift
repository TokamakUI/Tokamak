//
//  Constraint.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 14/01/2019.
//

import Gluon
import UIKit

extension Constraint.Size.Attribute {
  var anchor: KeyPath<UIView, NSLayoutDimension> {
    switch self {
    case .height:
      return \.heightAnchor
    case .width:
      return \.widthAnchor
    }
  }
}

extension Constraint.Size {
  func constraint(
    source: Attribute,
    current: UIView,
    parent: UIView,
    next: UIView?
  ) -> NSLayoutConstraint? {
    let firstAnchor = source.anchor
    let secondAnchor = attribute.anchor

    switch target {
    case .own:
      return current[keyPath: firstAnchor].constraint(
        equalToConstant: CGFloat(constant)
      )
    case let .external(target):
      let secondView: UIView
      switch target {
      case .next:
        guard let next = next else { return nil }

        secondView = next
      case .parent:
        secondView = parent
      }

      return current[keyPath: firstAnchor].constraint(
        equalTo: secondView[keyPath: secondAnchor],
        multiplier: CGFloat(multiplier),
        constant: CGFloat(constant)
      )
    }
  }
}

extension UIView {
  func constraint(
    _ constraint: Constraint,
    parent: UIView,
    next: UIView?
  ) -> NSLayoutConstraint? {
    switch constraint {
    case let .height(size):
      return size.constraint(
        source: .height,
        current: self,
        parent: parent,
        next: next
      )
    case let .width(size):
      return size.constraint(
        source: .width,
        current: self,
        parent: parent,
        next: next
      )
    case .baseline:
      fatalError()
    case .bottom:
      fatalError()
    case .center:
      fatalError()
    case .centerX:
      fatalError()
    case .centerY:
      fatalError()
    case .left:
      fatalError()
    case .right:
      fatalError()
    case .top:
      fatalError()
    }
  }
}
