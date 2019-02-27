//
//  Width.swift
//  Tokamak
//
//  Created by Max Desiatov on 02/02/2019.
//

public struct Width: Equatable {
  public let target: Constraint.OwnTarget
  public let constant: Double
  public let multiplier: Double

  public static func equal(
    to target: Constraint.Target,
    constant: Double = 0,
    multiplier: Double = 1
  ) -> Constraint {
    return .width(Width(
      target: .external(target), constant: constant, multiplier: multiplier
    ))
  }

  public static func equal(
    to target: Constraint.OwnTarget,
    constant: Double = 0,
    multiplier: Double = 1
  ) -> Constraint {
    return .width(Width(
      target: target, constant: constant, multiplier: multiplier
    ))
  }

  public static func equal(to constant: Double) -> Constraint {
    return .width(Width(
      target: .own, constant: constant, multiplier: 0
    ))
  }
}
