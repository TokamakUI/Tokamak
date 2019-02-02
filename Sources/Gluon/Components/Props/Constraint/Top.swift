//
//  Top.swift
//  Gluon
//
//  Created by Max Desiatov on 02/02/2019.
//

public struct Top: Equatable {
  public let target: Constraint.Target
  public let constant: Double

  public static func equal(
    to target: Constraint.Target,
    constant: Double = 0
  ) -> Constraint {
    return .top(Top(
      target: target, constant: constant
    ))
  }
}
