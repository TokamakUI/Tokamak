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
    _ constraint: Constraint,
    parent: UIView,
    next: UIView?
  ) -> NSLayoutConstraint {
    switch constraint {
    case let .height(height):
      switch height.target {
      case .own:
        return heightAnchor.constraint(equalToConstant: CGFloat(height.constant))
      case let .external(target):
        fatalError()
      }
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
    case .width:
      fatalError()
    }
  }
}
