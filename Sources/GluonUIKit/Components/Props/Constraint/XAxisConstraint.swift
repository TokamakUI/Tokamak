//
//  XAxisConstraint.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 17/01/2019.
//

import Gluon
import UIKit

protocol XAxisConstraint {
  var firstAnchor: KeyPath<Constrainable, NSLayoutXAxisAnchor> { get }
  var secondAnchor: KeyPath<Constrainable, NSLayoutXAxisAnchor> { get }
  var target: Constraint.Target { get }
  var constant: Double { get }
}

extension XAxisConstraint {
  func constraint(
    current: UIView,
    parent: UIView?,
    next: UIView?
  ) -> [NSLayoutConstraint] {
    let secondView: Constrainable?
    switch target {
    case .next:
      secondView = next
    case .parent:
      secondView = parent
    case .safeArea:
      if #available(iOS 11.0, *) {
        secondView = current.safeAreaLayoutGuide
      } else {
        secondView = parent
      }
    }

    guard let second = secondView?[keyPath: secondAnchor] else { return [] }

    return [current[keyPath: firstAnchor].constraint(
      equalTo: second,
      constant: CGFloat(constant)
    )]
  }
}
