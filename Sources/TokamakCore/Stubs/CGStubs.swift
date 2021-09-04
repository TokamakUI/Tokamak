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
#endif

#if !canImport(CoreGraphics)
// For cross-platform testing.
@_spi(Tests)
public struct _CGAffineTransform {
  // Internal for testing purposes.
  internal let _transform: AffineTransform
}
#else
public struct _CGAffineTransform {
  // Internal for testing purposes.
  internal private(set) var _transform: AffineTransform
}

/// An affine transformation matrix for use in drawing 2D graphics.
///
///     a   b   0
///     c   d   0
///     tx  ty  1
public typealias CGAffineTransform = _CGAffineTransform
#endif

extension _CGAffineTransform: Equatable {}

extension _CGAffineTransform: Codable {
  public init(from decoder: Decoder) throws {
    try self.init(
      _transform: AffineTransform(from: decoder)
    )
  }

  public func encode(to encoder: Encoder) throws {
    try _transform.encode(to: encoder)
  }
}

public extension _CGAffineTransform {
  /// The value at position [1,1] in the matrix.
  var a: CGFloat {
    get { _transform.m11 }
    set { _transform.m11 = newValue }
  }

  /// The value at position [1,2] in the matrix.
  var b: CGFloat {
    get { _transform.m12 }
    set { _transform.m12 = newValue }
  }

  /// The value at position [2,1] in the matrix.
  var c: CGFloat {
    get { _transform.m21 }
    set { _transform.m21 = newValue }
  }

  /// The value at position [2,2] in the matrix.
  var d: CGFloat {
    get { _transform.m22 }
    set { _transform.m22 = newValue }
  }

  /// The value at position [3,1] in the matrix.
  var tx: CGFloat {
    get { _transform.tX }
    set { _transform.tX = newValue }
  }

  /// The value at position [3,2] in the matrix.
  var ty: CGFloat {
    get { _transform.tY }
    set { _transform.tY = newValue }
  }

  /// Creates an affine transform with the given matrix values.
  ///
  /// - Parameters:
  ///   - a: The value at position [1,1] in the matrix.
  ///   - b: The value at position [1,2] in the matrix.
  ///   - c: The value at position [2,1] in the matrix.
  ///   - d: The value at position [2,2] in the matrix.
  ///   - tx: The value at position [3,1] in the matrix.
  ///   - ty: The value at position [3,2] in the matrix.
  init(
    a: CGFloat, b: CGFloat,
    c: CGFloat, d: CGFloat,
    tx: CGFloat, ty: CGFloat
  ) {
    self.init(_transform: AffineTransform(
      m11: a, m12: b,
      m21: c, m22: d,
      tX: tx, tY: ty
    ))
  }
}

public extension _CGAffineTransform {
  /// The identity transformation matrix.
  static let identity = Self(_transform: .identity)

  /// Creates the identity transformation matrix.
  init() {
    self.init(_transform: AffineTransform())
  }

  var isIdentity: Bool {
    self == .identity
  }
}

public extension _CGAffineTransform {
  /// Creates an affine transformation matrix constructed from a rotation value you
  /// provide.
  ///
  /// - Parameters:
  ///   - angle: The angle, in radians, by which this matrix rotates the coordinate
  ///   system axes. A positive value specifies clockwise rotation and a negative value
  ///   specifies counterclockwise rotation.
  init(rotationAngle angle: CGFloat) {
    self.init(_transform: AffineTransform(rotationByRadians: angle))
  }

  /// Creates an affine transformation matrix constructed from scaling values you provide.
  ///
  /// - Parameters:
  ///   - sx: The factor by which to scale the x-axis of the coordinate system.
  ///   - sy: The factor by which to scale the y-axis of the coordinate system.
  init(scaleX x: CGFloat, y: CGFloat) {
    self.init(_transform: AffineTransform(scaleByX: x, byY: y))
  }

  /// Creates an affine transformation matrix constructed from translation values you
  /// provide.
  ///
  /// - Parameters:
  ///   - tx: The value by which to move the x-axis of the coordinate system.
  ///   - ty: The value by which to move the y-axis of the coordinate system.
  init(translationX x: CGFloat, y: CGFloat) {
    self.init(_transform: AffineTransform(translationByX: x, byY: y))
  }
}

public extension _CGAffineTransform {
  private func withBackingTransform(
    _ modify: (inout AffineTransform) -> ()
  ) -> Self {
    var newTransform = _transform
    modify(&newTransform)

    return _CGAffineTransform(_transform: newTransform)
  }
}

public extension _CGAffineTransform {
  /// Returns an affine transformation matrix constructed by combining two existing affine
  /// transforms.
  ///
  /// Note that concatenation is not commutative, meaning that order is important. For
  /// instance, `t1.concatenating(t2)` != `t2.concatenating(t1)` — where
  /// `t1` and `t2` are`CGAffineTransform` instances.
  ///
  /// - Postcondition: The returned transformation is invertible if both `self` and
  /// the given transformation (`t2`) are invertible.
  ///
  /// - Parameters:
  ///   - t2: The affine transform to concatenate to this affine transform.
  /// - Returns: A new affine transformation matrix. That is, `t’ = t1*t2`.
  func concatenating(_ t2: Self) -> Self {
    withBackingTransform { $0.append(t2._transform) }
  }
}

public extension _CGAffineTransform {
  /// Returns an affine transformation matrix constructed by inverting an existing affine
  /// transform.
  ///
  /// - Postcondition: Invertibility is preserved, meaning that if `self` is
  /// invertible, so the returned transformation will also be invertible.
  ///
  /// - Returns: A new affine transformation matrix. If `self` is not invertible, it's
  /// returned unchanged.
  func inverted() -> Self {
    withBackingTransform { _transform in
      guard let inverted = _transform.inverted() else {
        fatalError("This affine transform is non invertible.")
      }

      _transform = inverted
    }
  }
}

public extension _CGAffineTransform {
  /// Returns an affine transformation matrix constructed by rotating an existing affine
  /// transform.
  ///
  /// - Parameters:
  ///   - angle: The angle, in radians, by which to rotate the affine transform.
  ///   A positive value specifies clockwise rotation and a negative value specifies
  ///   counterclockwise rotation.
  func rotated(by angle: CGFloat) -> Self {
    withBackingTransform { $0.rotate(byRadians: angle) }
  }

  /// Returns an affine transformation matrix constructed by scaling an existing affine
  /// transform.
  ///
  /// - Postcondition: Invertibility is preserved if both `sx` and `sy` aren't `0`.
  ///
  /// - Parameters:
  ///   - sx: The value by which to scale x values of the affine transform.
  ///   - sy: The value by which to scale y values of the affine transform.
  func scaledBy(x: CGFloat, y: CGFloat) -> Self {
    withBackingTransform { $0.scale(x: x, y: y) }
  }

  /// Returns an affine transformation matrix constructed by translating an existing
  /// affine transform.
  ///
  /// - Parameters:
  ///   - tx: The value by which to move x values with the affine transform.
  ///   - ty: The value by which to move y values with the affine transform.
  func translatedBy(x: CGFloat, y: CGFloat) -> Self {
    withBackingTransform { $0.translate(x: x, y: y) }
  }
}

internal extension _CGAffineTransform {
  func _transform(point: CGPoint) -> CGPoint {
    _transform.transform(point)
  }
}

public extension CGAffineTransform {
  /// Transform the point into the transform's coordinate system.
  func transform(point: CGPoint) -> CGPoint {
    let transform = _CGAffineTransform(
      a: a, b: b,
      c: c, d: d,
      tx: tx, ty: ty
    )

    return transform._transform(point: point)
  }
}
