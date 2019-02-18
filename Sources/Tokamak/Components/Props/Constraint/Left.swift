//
//  Left.swift
//  Tokamak
//
//  Created by Max Desiatov on 02/02/2019.
//

public struct Left: Equatable {
  public let target: Constraint.SafeAreaTarget
  public let constant: Double

  public static func equal(
    to target: Constraint.SafeAreaTarget,
    constant: Double = 0
  ) -> Constraint {
    return .left(Left(
      target: target, constant: constant
    ))
  }

  public static func equal(
    to target: Constraint.Target,
    constant: Double = 0
  ) -> Constraint {
    return .left(Left(
      target: .external(target), constant: constant
    ))
  }
}
