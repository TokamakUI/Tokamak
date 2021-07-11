// Copyright 2018-2020 Tokamak contributors
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
//  Created by Max Desiatov on 06/28/2020.
//

public struct Angle: AdditiveArithmetic {
  public var radians: Double
  public var degrees: Double {
    get { radians * (180.0 / .pi) }
    set { radians = newValue * (.pi / 180.0) }
  }

  public init() {
    self.init(radians: 0.0)
  }

  public init(radians: Double) {
    self.radians = radians
  }

  public init(degrees: Double) {
    self.init(radians: degrees * (.pi / 180.0))
  }

  public static func radians(_ radians: Double) -> Angle {
    Angle(radians: radians)
  }

  public static func degrees(_ degrees: Double) -> Angle {
    Angle(degrees: degrees)
  }

  public static let zero: Angle = .radians(0)

  public static func + (lhs: Self, rhs: Self) -> Self {
    .radians(lhs.radians + rhs.radians)
  }

  public static func += (lhs: inout Self, rhs: Self) {
    // swiftlint:disable:next shorthand_operator
    lhs = lhs + rhs
  }

  public static func - (lhs: Self, rhs: Self) -> Self {
    .radians(lhs.radians - rhs.radians)
  }

  public static func -= (lhs: inout Self, rhs: Self) {
    // swiftlint:disable:next shorthand_operator
    lhs = lhs - rhs
  }
}

extension Angle: Hashable, Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.radians < rhs.radians
  }
}

extension Angle: Animatable, _VectorMath {
  public var animatableData: Double {
    get { radians }
    set { radians = newValue }
  }
}
