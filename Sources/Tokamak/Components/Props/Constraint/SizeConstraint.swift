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
  public static func equal(to size: Double) -> Constraint {
    return .size(.constant(Size(width: size, height: size)))
  }

  public static func equal(to size: Size) -> Constraint {
    return .size(.constant(size))
  }

  public static func equal(
    to target: Constraint.Target,
    multiplier: Double = 1.0
  ) -> Constraint {
    return .size(.multiplier(target, multiplier))
  }
}
