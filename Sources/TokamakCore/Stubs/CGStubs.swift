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
//  Created by Max Desiatov on 08/04/2020.
//

import CoreFoundation
import Foundation

extension CGPoint {
  func rotate(_ angle: Angle, around origin: Self) -> Self {
    let cosAngle = CGFloat(cos(angle.radians))
    let sinAngle = CGFloat(sin(angle.radians))
    return .init(
      x: cosAngle * (x - origin.x) - sinAngle * (y - origin.y) + origin.x,
      y: sinAngle * (x - origin.x) + cosAngle * (y - origin.y) + origin.y
    )
  }

  func offset(by offset: Self) -> Self {
    .init(
      x: x + offset.x,
      y: y + offset.y
    )
  }
}

public extension CGAffineTransform {
  /// Transform the point into the transform's coordinate system.
  func transform(point: CGPoint) -> CGPoint {
    CGPoint(
      x: (a * point.x) + (c * point.y) + tx,
      y: (b * point.x) + (d * point.y) + ty
    )
  }
}

#if !canImport(CoreGraphics)
public enum CGLineCap {
  /// A line with a squared-off end. Extends to the endpoint of the Path.
  case butt
  /// A line with a rounded end. Extends past the endpoint of the Path.
  case round
  /// A line with a squared-off end. Extends past the endpoint of the Path.
  case square
}

public enum CGLineJoin {
  case miter
  /// A join with a rounded end. Extends past the endpoint of the Path.
  case round
  /// A join with a squared-off end. Extends past the endpoint of the Path.
  case bevel
}

/// An affine transformation matrix for use in drawing 2D graphics.
///
///     a   b   0
///     c   d   0
///     tx  ty  1
public struct CGAffineTransform: Equatable {
  public var a: CGFloat
  public var b: CGFloat
  public var c: CGFloat
  public var d: CGFloat
  public var tx: CGFloat
  public var ty: CGFloat

  /// The identity matrix
  public static let identity: Self = .init(
    a: 1,
    b: 0, // 0
    c: 0,
    d: 1, // 0
    tx: 0,
    ty: 0
  ) // 1

  public init(
    a: CGFloat, b: CGFloat,
    c: CGFloat, d: CGFloat,
    tx: CGFloat, ty: CGFloat
  ) {
    self.a = a
    self.b = b
    self.c = c
    self.d = d
    self.tx = tx
    self.ty = ty
  }

  /// Returns an affine transformation matrix constructed from a rotation value you provide.
  /// - Parameters:
  ///   - angle: The angle, in radians, by which this matrix rotates the coordinate system axes.
  ///            A positive value specifies clockwise rotation and a negative value specifies
  ///            counterclockwise rotation.
  public init(rotationAngle angle: CGFloat) {
    self.init(a: cos(angle), b: sin(angle), c: -sin(angle), d: cos(angle), tx: 0, ty: 0)
  }

  /// Returns an affine transformation matrix constructed from scaling values you provide.
  /// - Parameters:
  ///   - sx: The factor by which to scale the x-axis of the coordinate system.
  ///   - sy: The factor by which to scale the y-axis of the coordinate system.
  public init(scaleX sx: CGFloat, y sy: CGFloat) {
    self.init(
      a: sx,
      b: 0,
      c: 0,
      d: sy,
      tx: 0,
      ty: 0
    )
  }

  /// Returns an affine transformation matrix constructed from translation values you provide.
  /// - Parameters:
  ///   - tx: The value by which to move the x-axis of the coordinate system.
  ///   - ty: The value by which to move the y-axis of the coordinate system.
  public init(translationX tx: CGFloat, y ty: CGFloat) {
    self.init(
      a: 1,
      b: 0,
      c: 0,
      d: 1,
      tx: tx,
      ty: ty
    )
  }

  /// Returns an affine transformation matrix constructed by combining two existing affine
  /// transforms.
  /// - Parameters:
  ///   - t2: The affine transform to concatenate to this affine transform.
  /// - Returns: A new affine transformation matrix. That is, `t’ = t1*t2`.
  public func concatenating(_ t2: Self) -> Self {
    let t1m = [[a, b, 0],
               [c, d, 0],
               [tx, ty, 1]]
    let t2m = [[t2.a, t2.b, 0],
               [t2.c, t2.d, 0],
               [t2.tx, t2.ty, 1]]
    var res: [[CGFloat]] = [[0, 0, 0],
                            [0, 0, 0],
                            [0, 0, 0]]
    for i in 0..<3 {
      for j in 0..<3 {
        res[i][j] = 0
        for k in 0..<3 {
          res[i][j] += t1m[i][k] * t2m[k][j]
        }
      }
    }
    return .init(
      a: res[0][0],
      b: res[0][1],
      c: res[1][0],
      d: res[1][1],
      tx: res[2][0],
      ty: res[2][1]
    )
  }

  /// Returns an affine transformation matrix constructed by inverting an existing affine transform.
  public func inverted() -> Self {
    .init(a: -a, b: -b, c: -c, d: -d, tx: -tx, ty: -ty)
  }

  /// Returns an affine transformation matrix constructed by rotating an existing affine transform.
  /// - Parameters:
  ///   - angle: The angle, in radians, by which to rotate the affine transform.
  ///   A positive value specifies clockwise rotation and a negative value specifies
  ///   counterclockwise rotation.
  public func rotated(by angle: CGFloat) -> Self {
    Self(a: cos(angle), b: sin(angle), c: -sin(angle), d: cos(angle), tx: 0, ty: 0)
  }

  /// Returns an affine transformation matrix constructed by translating an existing
  /// affine transform.
  /// - Parameters:
  ///   - tx: The value by which to move x values with the affine transform.
  ///   - ty: The value by which to move y values with the affine transform.
  public func translatedBy(x tx: CGFloat, y ty: CGFloat) -> Self {
    .init(a: a, b: b, c: c, d: d, tx: self.tx + tx, ty: self.ty + ty)
  }

  /// Returns an affine transformation matrix constructed by scaling an existing affine transform.
  /// - Parameters:
  ///   - sx: The value by which to scale x values of the affine transform.
  ///   - sy: The value by which to scale y values of the affine transform.
  public func scaledBy(x sx: CGFloat, y sy: CGFloat) -> Self {
    .init(a: a + sx, b: b, c: c, d: d + sy, tx: tx, ty: ty)
  }

  public var isIdentity: Bool {
    self == Self.identity
  }
}

#endif
