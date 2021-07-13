// Copyright 2020-2021 Tokamak contributors
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
//  Created by Carson Katri on 7/3/20.
//

import Foundation

// FIXME: Make `Animatable`
public protocol GeometryEffect: Animatable, ViewModifier {
  func effectValue(size: CGSize) -> ProjectionTransform
}

public struct ProjectionTransform: Equatable {
  public var m11: CGFloat = 1, m12: CGFloat = 0, m13: CGFloat = 0
  public var m21: CGFloat = 0, m22: CGFloat = 1, m23: CGFloat = 0
  public var m31: CGFloat = 0, m32: CGFloat = 0, m33: CGFloat = 1
  public init() {}
  public init(_ m: CGAffineTransform) {
    m11 = m.a
    m12 = m.b
    m21 = m.c
    m22 = m.d
    m31 = m.tx
    m32 = m.ty
  }

  public var isIdentity: Bool {
    self == ProjectionTransform()
  }

  public var isAffine: Bool {
    m13 == 0 && m23 == 0 && m33 == 1
  }

  public mutating func invert() -> Bool {
    self = inverted()
    return true
  }

  public func inverted() -> ProjectionTransform {
    .init(CGAffineTransform(a: m11, b: m12, c: m21, d: m22, tx: m31, ty: m32).inverted())
  }
}
