// Copyright 2020 Tokamak contributors
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
//
//  Created by Carson Katri on 7/11/21.
//

import Foundation

public protocol Animatable {
  associatedtype AnimatableData: VectorArithmetic
  var animatableData: Self.AnimatableData { get set }
}

public protocol _PrimitiveAnimatable {}

public extension Animatable where Self: VectorArithmetic {
  var animatableData: Self {
    get { self }
    // swiftlint:disable:next unused_setter_value
    set {}
  }
}

public extension Animatable where Self.AnimatableData == EmptyAnimatableData {
  var animatableData: EmptyAnimatableData {
    @inlinable get { EmptyAnimatableData() }
    // swiftlint:disable:next unused_setter_value
    @inlinable set {}
  }
}

@frozen
public struct EmptyAnimatableData: VectorArithmetic {
  @inlinable
  public init() {}

  @inlinable
  public static var zero: Self { .init() }

  @inlinable
  public static func += (lhs: inout Self, rhs: Self) {}

  @inlinable
  public static func -= (lhs: inout Self, rhs: Self) {}

  @inlinable
  public static func + (lhs: Self, rhs: Self) -> Self {
    .zero
  }

  @inlinable
  public static func - (lhs: Self, rhs: Self) -> Self {
    .zero
  }

  @inlinable
  public mutating func scale(by rhs: Double) {}

  @inlinable
  public var magnitudeSquared: Double { .zero }

  public static func == (a: Self, b: Self) -> Bool { true }
}

@frozen
public struct AnimatablePair<First, Second>: VectorArithmetic
  where First: VectorArithmetic, Second: VectorArithmetic
{
  public var first: First
  public var second: Second
  @inlinable
  public init(_ first: First, _ second: Second) {
    self.first = first
    self.second = second
  }

  @inlinable
  internal subscript() -> (First, Second) {
    get { (first, second) }
    set { (first, second) = newValue }
  }

  @_transparent
  public static var zero: Self {
    @_transparent get {
      .init(First.zero, Second.zero)
    }
  }

  @_transparent
  public static func += (lhs: inout Self, rhs: Self) {
    lhs.first += rhs.first
    lhs.second += rhs.second
  }

  @_transparent
  public static func -= (lhs: inout Self, rhs: Self) {
    lhs.first -= rhs.first
    lhs.second -= rhs.second
  }

  @_transparent
  public static func + (lhs: Self, rhs: Self) -> Self {
    .init(lhs.first + rhs.first, lhs.second + rhs.second)
  }

  @_transparent
  public static func - (lhs: Self, rhs: Self) -> Self {
    .init(lhs.first - rhs.first, lhs.second - rhs.second)
  }

  @_transparent
  public mutating func scale(by rhs: Double) {
    first.scale(by: rhs)
    second.scale(by: rhs)
  }

  @_transparent
  public var magnitudeSquared: Double {
    @_transparent get {
      first.magnitudeSquared + second.magnitudeSquared
    }
  }

  public static func == (a: Self, b: Self) -> Bool {
    a.first == b.first
      && a.second == b.second
  }
}

extension CGPoint: Animatable {
  public var animatableData: AnimatablePair<CGFloat, CGFloat> {
    @inlinable get { .init(x, y) }
    @inlinable set { (x, y) = newValue[] }
  }
}

extension CGSize: Animatable {
  public var animatableData: AnimatablePair<CGFloat, CGFloat> {
    @inlinable get { .init(width, height) }
    @inlinable set { (width, height) = newValue[] }
  }
}

extension CGRect: Animatable {
  public var animatableData: AnimatablePair<CGPoint.AnimatableData, CGSize.AnimatableData> {
    @inlinable get {
      .init(origin.animatableData, size.animatableData)
    }
    @inlinable set {
      (origin.animatableData, size.animatableData) = newValue[]
    }
  }
}
