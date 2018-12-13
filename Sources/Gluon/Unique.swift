//
//  Unique.swift
//  Gluon
//
//  Created by Max Desiatov on 06/11/2018.
//

import Foundation

public typealias Handler<T> = Unique<(T) -> ()>

class UniqueReference {}

extension UniqueReference: Equatable {
  public static func ==(lhs: UniqueReference, rhs: UniqueReference) -> Bool {
    return lhs === rhs
  }
}

public struct Unique<T> {
  private let id = UniqueReference()
  public let value: T

  public init(_ value: T) {
    self.value = value
  }
}

extension Unique: Equatable {
  public static func ==(lhs: Unique<T>, rhs: Unique<T>) -> Bool {
    return lhs.id == rhs.id
  }
}
