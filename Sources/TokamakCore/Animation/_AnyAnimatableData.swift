// Copyright 2022 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// A type-eraser for `VectorArithmetic`.
public struct _AnyAnimatableData: VectorArithmetic {
  private var box: _AnyAnimatableDataBox?

  private init(_ box: _AnyAnimatableDataBox?) {
    self.box = box
  }
}

/// A box for vector arithmetic types.
///
/// Conforming types are only expected to handle value types (enums and structs).
/// Classes aren't really mutable so that scaling, but even then subclassing is impossible,
/// at least in my attempts. Also `VectorArithmetic` does not have a self-conforming
/// existential. Thus the problem of two types being equal but not sharing a common
/// supertype is avoided. Consider a type `Super` that has subtypes `A : Super` and
/// `B : Super`; casting both `A.self as? B.Type` and `B.self as? A.Type` fail.
/// This is important for static operators, since non-type-erased operators get this right.
/// Thankfully, only no-inheritance types are supported.
private protocol _AnyAnimatableDataBox {
  var value: Any { get }

  func equals(_ other: Any) -> Bool

  func add(_ other: Any) -> _AnyAnimatableDataBox
  func subtract(_ other: Any) -> _AnyAnimatableDataBox

  mutating func scale(by scalar: Double)
  var magnitudeSquared: Double { get }
}

private struct _ConcreteAnyAnimatableDataBox<
  Base: VectorArithmetic
>: _AnyAnimatableDataBox {
  var base: Base

  var value: Any {
    base
  }

  // MARK: Equatable

  func equals(_ other: Any) -> Bool {
    guard let other = other as? Base else {
      return false
    }

    return base == other
  }

  // MARK: AdditiveArithmetic

  func add(_ other: Any) -> _AnyAnimatableDataBox {
    guard let other = other as? Base else {
      // TODO: Look into whether this should crash.
      // SwiftUI didn't crash on the first beta.
      return self
    }

    return Self(base: base + other)
  }

  func subtract(_ other: Any) -> _AnyAnimatableDataBox {
    guard let other = other as? Base else {
      // TODO: Look into whether this should crash.
      // SwiftUI didn't crash on the first beta.
      return self
    }

    return Self(base: base - other)
  }

  // MARK: VectorArithmetic

  mutating func scale(by scalar: Double) {
    base.scale(by: scalar)
  }

  var magnitudeSquared: Double {
    base.magnitudeSquared
  }
}

public extension _AnyAnimatableData {
  // MARK: Equatable

  static func == (lhs: Self, rhs: Self) -> Bool {
    switch (rhs.box, lhs.box) {
    case let (rhsBox?, lhsBox?):
      return rhsBox.equals(lhsBox.value)

    case (.some, nil), (nil, .some):
      return false

    case (nil, nil):
      return true
    }
  }

  // MARK: AdditiveArithmetic

  static func + (lhs: Self, rhs: Self) -> Self {
    switch (rhs.box, lhs.box) {
    case let (rhsBox?, lhsBox?):
      return Self(rhsBox.add(lhsBox.value))

    case (let box?, nil), (nil, let box?):
      return Self(box)

    case (nil, nil):
      return lhs
    }
  }

  static func - (lhs: Self, rhs: Self) -> Self {
    switch (rhs.box, lhs.box) {
    case let (rhsBox?, lhsBox?):
      return Self(rhsBox.subtract(lhsBox.value))

    case (let box?, nil), (nil, let box?):
      return Self(box)

    case (nil, nil):
      return lhs
    }
  }

  static var zero: _AnyAnimatableData {
    _AnyAnimatableData(nil)
  }

  // MARK: VectorArithmetic

  mutating func scale(by rhs: Double) {
    box?.scale(by: rhs)
  }

  var magnitudeSquared: Double {
    box?.magnitudeSquared ?? 0
  }
}

public extension _AnyAnimatableData {
  init<Data: VectorArithmetic>(_ data: Data) {
    box = _ConcreteAnyAnimatableDataBox(base: data)
  }

  var value: Any {
    box?.value ?? ()
  }
}
