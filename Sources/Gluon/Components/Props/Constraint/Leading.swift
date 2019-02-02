//
//  Leading.swift
//  Gluon
//
//  Created by Max Desiatov on 02/02/2019.
//

public struct Leading: Equatable {
  public let target: Constraint.Target
  public let constant: Double
  public let multiplier: Double

  public static func equal(
    to target: Constraint.Target,
    constant: Double = 0,
    multiplier: Double = 1
  ) -> Constraint {
    return .leading(Leading(
      target: target, constant: constant, multiplier: multiplier
    ))
  }
}
