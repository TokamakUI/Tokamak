//
//  SizeConstraint.swift
//  Tokamak
//
//  Created by Max Desiatov on 02/02/2019.
//

public enum SizeConstraint: Equatable {
  case constant(Size)
  case multiplier(Constraint.Target, Double)
}

extension Size {
  static func equal(to size: Size) -> SizeConstraint {
    return .constant(size)
  }

  static func equal(
    to target: Constraint.Target,
    multiplier: Double = 1.0
  ) -> SizeConstraint {
    return .multiplier(target, multiplier)
  }
}
