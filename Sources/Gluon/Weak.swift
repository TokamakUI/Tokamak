//
//  Weak.swift
//  Gluon
//
//  Created by Max Desiatov on 27/01/2019.
//

public struct Weak<T: AnyObject> {
  weak var value: T?

  public init(value: T) {
    self.value = value
  }
}

extension Weak: Equatable {
  public static func ==(lhs: Weak<T>, rhs: Weak<T>) -> Bool {
    return lhs.value === rhs.value
  }
}

extension Weak: Hashable {
  public func hash(into hasher: inout Hasher) {
    guard let value = value else { return }

    hasher.combine(ObjectIdentifier(value))
  }
}
