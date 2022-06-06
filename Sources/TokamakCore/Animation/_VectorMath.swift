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

public protocol _VectorMath: Animatable {}

public extension _VectorMath {
  @inlinable
  var magnitude: Double {
    animatableData.magnitudeSquared.squareRoot()
  }

  @inlinable
  mutating func negate() {
    animatableData = .zero - animatableData
  }

  @inlinable
  static prefix func - (operand: Self) -> Self {
    var result = operand
    result.negate()
    return result
  }

  @inlinable
  static func += (lhs: inout Self, rhs: Self) {
    lhs.animatableData += rhs.animatableData
  }

  @inlinable
  static func + (lhs: Self, rhs: Self) -> Self {
    var result = lhs
    result += rhs
    return result
  }

  @inlinable
  static func -= (lhs: inout Self, rhs: Self) {
    lhs.animatableData -= rhs.animatableData
  }

  @inlinable
  static func - (lhs: Self, rhs: Self) -> Self {
    var result = lhs
    result -= rhs
    return result
  }

  @inlinable
  static func *= (lhs: inout Self, rhs: Double) {
    lhs.animatableData.scale(by: rhs)
  }

  @inlinable
  static func * (lhs: Self, rhs: Double) -> Self {
    var result = lhs
    result *= rhs
    return result
  }

  @inlinable
  static func /= (lhs: inout Self, rhs: Double) {
    lhs *= 1 / rhs
  }

  @inlinable
  static func / (lhs: Self, rhs: Double) -> Self {
    var result = lhs
    result /= rhs
    return result
  }
}
