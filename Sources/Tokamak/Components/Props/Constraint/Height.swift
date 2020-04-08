//
//  Height.swift
//  Tokamak
//
//  Created by Max Desiatov on 02/02/2019.
//

public struct Height: Equatable {
  public let target: Constraint.OwnTarget
  public let constant: Double
  public let multiplier: Double

  public static func equal(
    to target: Constraint.Target,
    constant: Double = 0,
    multiplier: Double = 1
  ) -> Constraint {
    .height(Height(
      target: .external(target), constant: constant, multiplier: multiplier
    ))
  }

  public static func equal(
    to target: Constraint.OwnTarget,
    constant: Double = 0,
    multiplier: Double = 1
  ) -> Constraint {
    .height(Height(
      target: target, constant: constant, multiplier: multiplier
    ))
  }

  public static func equal(to constant: Double) -> Constraint {
    .height(Height(
      target: .own, constant: constant, multiplier: 0
    ))
  }
}
