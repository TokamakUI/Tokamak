//
//  AnyEquatable.swift
//  Gluon
//
//  Created by Max Desiatov on 06/11/2018.
//


public struct AnyEquatable: Equatable {
  let value: Any
  private let equals: (Any) -> Bool

  public init<E: Equatable>(_ value: E) {
    self.value = value
    self.equals = { ($0 as? E) == value }
  }

  public static func == (lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
    return lhs.equals(rhs.value) || rhs.equals(lhs.value)
  }
}
