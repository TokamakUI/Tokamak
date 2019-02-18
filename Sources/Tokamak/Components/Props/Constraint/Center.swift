//
//  Center.swift
//  Tokamak
//
//  Created by Max Desiatov on 02/02/2019.
//

public struct Center: Equatable {
  public let target: Constraint.Target
  public let constant: Double

  public static func equal(
    to target: Constraint.Target,
    constant: Double = 0
  ) -> Constraint {
    return .center(Center(target: target, constant: constant))
  }
}
