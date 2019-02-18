//
//  BaselineConstraint.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 03/02/2019.
//

import Tokamak
import UIKit

protocol BaselineConstraint {
  var firstAnchor: KeyPath<UIView, NSLayoutYAxisAnchor> { get }
  var secondAnchor: KeyPath<UIView, NSLayoutYAxisAnchor> { get }
  var target: Constraint.Target { get }
  var constant: Double { get }
}

extension BaselineConstraint {
  func constraint(
    current: UIView,
    parent: UIView?,
    next: UIView?
  ) -> [NSLayoutConstraint] {
    let secondView: UIView?
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
