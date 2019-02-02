//
//  CenterX.swift
//  Gluon
//
//  Created by Max Desiatov on 02/02/2019.
//

public struct CenterX: Equatable {
  public let target: Constraint.Target
  public let constant: Double
  public let multiplier: Double

  public static func equal(
    to target: Constraint.Target,
    constant: Double = 0,
    multiplier: Double = 1
  ) -> Constraint {
    return .centerX(CenterX(
      target: target, constant: constant, multiplier: multiplier
    ))
  }
}
