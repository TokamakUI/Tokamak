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

#warning("Remove `|| true` before merging.")
#if !canImport(CoreGraphics) || true
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
public struct CGAffineTransform: Equatable, Codable {
  /// The value at position [1,1] in the matrix.
  public var a: CGFloat
  /// The value at position [1,2] in the matrix.
  public var b: CGFloat
  /// The value at position [2,1] in the matrix.
  public var c: CGFloat
  /// The value at position [2,2] in the matrix.
  public var d: CGFloat
  /// The value at position [3,1] in the matrix.
  public var tx: CGFloat
  /// The value at position [3,2] in the matrix.
  public var ty: CGFloat

  /// Creates an affine transform with the given matrix values.
  /// - Parameters:
  ///   - a: The value at position [1,1] in the matrix.
  ///   - b: The value at position [1,2] in the matrix.
  ///   - c: The value at position [2,1] in the matrix.
  ///   - d: The value at position [2,2] in the matrix.
  ///   - tx: The value at position [3,1] in the matrix.
  ///   - ty: The value at position [3,2] in the matrix.
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
}

public extension CGAffineTransform {
  /// The identity matrix.
  static let identity = Self(
    a: 1, b: 0, // 0
    c: 0, d: 1, // 0
    tx: 0, ty: 0 // 1
  )

  init() {
    self = .identity
  }

  var isIdentity: Bool {
    self == .identity
  }
}

public extension CGAffineTransform {
  /// Returns an affine transformation matrix constructed from a rotation value you provide.
  /// - Parameters:
  ///   - angle: The angle, in radians, by which this matrix rotates the coordinate
  ///   system axes. A positive value specifies clockwise rotation and a negative value
  ///    specifies counterclockwise rotation.
  init(rotationAngle angle: CGFloat) {
    let angleSine = sin(angle)
    let angleCosine = cos(angle)

    self.init(
      a: angleCosine, b: angleSine,
      c: -angleSine, d: angleCosine,
      tx: 0, ty: 0
    )
  }

  /// Returns an affine transformation matrix constructed from scaling values you provide.
  /// - Parameters:
  ///   - sx: The factor by which to scale the x-axis of the coordinate system.
  ///   - sy: The factor by which to scale the y-axis of the coordinate system.
  init(scaleX sx: CGFloat, y sy: CGFloat) {
    self.init(
      a: sx, b: 0,
      c: 0, d: sy,
      tx: 0, ty: 0
    )
  }

  /// Returns an affine transformation matrix constructed from translation values you provide.
  /// - Parameters:
  ///   - tx: The value by which to move the x-axis of the coordinate system.
  ///   - ty: The value by which to move the y-axis of the coordinate system.
  init(translationX tx: CGFloat, y ty: CGFloat) {
    self.init(
      a: 1, b: 0,
      c: 0, d: 1,
      tx: tx, ty: ty
    )
  }
}

public extension CGAffineTransform {
  /// Returns an affine transformation matrix constructed by combining two existing affine
  /// transforms.
  ///
  /// Note that concatenation is not commutative, meaning that order is important. For instance, `t1.concatenating(t2)` != `t2.concatenating(t1)` — where `t1` and
  /// `t2` are`CGAffineTransform` instances.
  ///
  /// - Parameters:
  ///   - t2: The affine transform to concatenate to this affine transform.
  /// - Returns: A new affine transformation matrix. That is, `t’ = t1*t2`.
  func concatenating(_ t2: Self) -> Self {
    let t1 = self

    return CGAffineTransform(
      a: (t1.a * t2.a) + (t1.b * t2.c),
      b: (t1.a * t2.b) + (t1.b * t2.d),
      c: (t1.c * t2.a) + (t1.d * t2.c),
      d: (t1.c * t2.b) + (t1.d * t2.d),
      tx: (t1.tx * t2.a) + (t1.ty * t2.c) + t2.tx,
      ty: (t1.tx * t2.b) + (t1.ty * t2.d) + t2.ty
    )
  }
}

public extension CGAffineTransform {
  /// Returns an affine transformation matrix constructed by inverting an existing affine transform.
  /// - Returns: A new affine transformation matrix. If the affine transform passed in
  /// parameter t cannot be inverted, the affine transform is returned unchanged.
  func inverted() -> Self {
    let determinant = (a * d) - (b * c)

    guard determinant != 0 else { return self }

    return Self(
      a: d / determinant, b: -b / determinant,
      c: -c / determinant, d: a / determinant,
      tx: (c * ty - d * tx) / determinant,
      ty: (b * tx - a * ty) / determinant
    )
  }
}

// TODO: - Optimize operators.
public extension CGAffineTransform {
  /// Returns an affine transformation matrix constructed by rotating an existing affine transform.
  ///
  /// - Parameters:
  ///   - angle: The angle, in radians, by which to rotate the affine transform.
  ///   A positive value specifies clockwise rotation and a negative value specifies
  ///   counterclockwise rotation.
  func rotated(by angle: CGFloat) -> Self {
    Self(rotationAngle: angle).concatenating(self)
  }

  /// Returns an affine transformation matrix constructed by scaling an existing affine transform.
  ///
  /// - Parameters:
  ///   - sx: The value by which to scale x values of the affine transform.
  ///   - sy: The value by which to scale y values of the affine transform.
  func scaledBy(x sx: CGFloat, y sy: CGFloat) -> Self {
    Self(scaleX: sx, y: sy).concatenating(self)
  }

  /// Returns an affine transformation matrix constructed by translating an existing
  /// affine transform.
  ///
  /// - Parameters:
  ///   - tx: The value by which to move x values with the affine transform.
  ///   - ty: The value by which to move y values with the affine transform.
  func translatedBy(x tx: CGFloat, y ty: CGFloat) -> Self {
    // To translate, we concatenate the translation matrix (T) with self (A):
    //
    //       [ 1   0   0 ]   [ a   b   0 ]
    // A×B = [ 0   1   0 ] × [ c   d   0 ]
    //       [ tx  ty  1 ]   [ x   y   1 ]
    //
    //       [   1*a+0*c       1*b+0*d         0 ]
    // A×B = [   0*a+1*c       0*b+1*d         0 ]
    //       [ tx*a+ty*c+x   tx*b+ty*d+y       1 ]
    //
    //       [      a           b          0 ]
    // A×B = [      c           d          0 ]
    //       [ tx*a+ty*c+x  tx*b+ty*d+y    1 ]

    Self(
      a: a, b: b,
      c: c, d: d,
      tx: tx * a + ty * c + self.tx, ty: tx * b + ty * d + self.ty
    )
  }
}

#endif
