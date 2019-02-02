//
//  SizeConstraint.swift
//  Gluon
//
//  Created by Max Desiatov on 02/02/2019.
//

public struct SizeConstraint: Equatable {
  enum Value {
    case constant(Size)
    case multiplier(Double)
  }
}
