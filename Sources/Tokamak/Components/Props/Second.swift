//
//  Second.swift
//  Tokamak
//
//  Created by Max Desiatov on 05/01/2019.
//

public struct Second: ExpressibleByFloatLiteral, Equatable {
  public let value: Double

  public init(floatLiteral value: Double) {
    self.value = value
  }

  public init(_ value: Double) {
    self.value = value
  }
}
