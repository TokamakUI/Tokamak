//
//  Unique.swift
//  Gluon
//
//  Created by Max Desiatov on 06/11/2018.
//

/// Typealias for closures returning no value and wrapped with `Unique`.
public typealias Handler<T> = Unique<(T) -> ()>

/// Classes have identity even when they have no content. `UniqueReference`
/// defines `Equatable` as an identity comparison.
class UniqueReference {}

extension UniqueReference: Equatable {
  public static func ==(lhs: UniqueReference, rhs: UniqueReference) -> Bool {
    return lhs === rhs
  }
}

/// `Unique` works around the fact that `ObjectIdentifier` can't take
/// closures as arguments despite closures being reference types and having
/// identity. `Unique` implements `Equatable`, but will return `false` on
/// equality comparison of different identities (including closures).
public struct Unique<T> {
  private let id = UniqueReference()

  /// Unpacked value stored within `Unique` container.
  public let value: T

  /// Create a new `Unique` container.
  public init(_ value: T) {
    self.value = value
  }
}

extension Unique: Equatable {
  public static func ==(lhs: Unique<T>, rhs: Unique<T>) -> Bool {
    return lhs.id == rhs.id
  }
}
