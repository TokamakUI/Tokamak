//
//  SizeConstraint.swift
//  Gluon
//
//  Created by Max Desiatov on 02/02/2019.
//

public struct SizeConstraint: Equatable {
  public enum Value: Equatable {
    case constant(Size)
    case multiplier(Constraint.Target, Double)
  }

  public let value: Value
}
