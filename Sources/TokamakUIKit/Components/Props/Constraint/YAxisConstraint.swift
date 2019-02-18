//
//  YAxisConstraint.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 02/02/2019.
//

import Tokamak
import UIKit

protocol YAxisConstraint {
  var firstAnchor: KeyPath<Constrainable, NSLayoutYAxisAnchor> { get }
  var secondAnchor: KeyPath<Constrainable, NSLayoutYAxisAnchor> { get }
  var target: Constraint.SafeAreaTarget { get }
  var constant: Double { get }
}

extension YAxisConstraint {
  func constraint(
    current: UIView,
    parent: UIView?,
    next: UIView?
  ) -> [NSLayoutConstraint] {
    let secondView: Constrainable?
    switch target {
    case .external(.next):
      secondView = next
    case .external(.parent):
      secondView = parent
    case .safeArea:
      secondView = parent?.safeAreaLayoutGuide
    }

    guard let second = secondView?[keyPath: secondAnchor] else { return [] }

    return [current[keyPath: firstAnchor].constraint(
      equalTo: second,
      constant: CGFloat(constant)
    )]
  }
}
