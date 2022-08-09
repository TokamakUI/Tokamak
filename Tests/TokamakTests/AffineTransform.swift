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

@_spi(Tests)
@testable import TokamakCore

import XCTest

typealias CGAffineTransform = TokamakCore._CGAffineTransform

// MARK: - Tests

final class CGAffineTransformTest: XCTestCase {
  private let accuracyThreshold = 0.001

  static var allTests: [(String, (CGAffineTransformTest) -> () throws -> ())] {
    [
      ("testConstruction", testConstruction),
      ("testVectorTransformations", testVectorTransformations),
      ("testIdentityConstruction", testIdentityConstruction),
      ("testIdentity", testIdentity),
      ("testTranslationConstruction", testTranslationConstruction),
      ("testTranslation", testTranslation),
      ("testScalingConstruction", testScalingConstruction),
      ("testScaling", testScaling),
      ("testRotationConstruction", testRotationConstruction),
      ("testRotation", testRotation),
      ("testTranslationScaling", testTranslationScaling),
      ("testTranslationRotation", testTranslationRotation),
      ("testScalingRotation", testScalingRotation),
      ("testInversion", testInversion),
      ("testConcatenation", testConcatenation),
      ("testCoding", testCoding),
    ]
  }
}

// MARK: - Helper

extension CGAffineTransformTest {
  func check(
    point: CGPoint,
    withTransform transform: CGAffineTransform,
    mapsTo expectedPoint: CGPoint,
    _ message: String = "",
    file: StaticString = #file, line: UInt = #line
  ) {
    let newPoint = transform.transform(point: point)

    XCTAssertEqual(
      newPoint.x, expectedPoint.x,
      accuracy: accuracyThreshold,
      "Invalid x: \(message)",
      file: file, line: line
    )

    XCTAssertEqual(
      newPoint.y, expectedPoint.y,
      accuracy: accuracyThreshold,
      "Invalid y: \(message)",
      file: file, line: line
    )
  }
}

// MARK: - Construction

extension CGAffineTransformTest {
  func testConstruction() {
    let transform = CGAffineTransform(
      a: 1, b: 2,
      c: 3, d: 4,
      tx: 5, ty: 6
    )

    XCTAssertEqual(transform.a, 1)
    XCTAssertEqual(transform.b, 2)
    XCTAssertEqual(transform.c, 3)
    XCTAssertEqual(transform.d, 4)
    XCTAssertEqual(transform.tx, 5)
    XCTAssertEqual(transform.ty, 6)

    let mutatedTransform: CGAffineTransform = {
      var copy = transform

      copy.a = -1
      copy.b = -2
      copy.c = -3
      copy.d = -4
      copy.tx = -5
      copy.ty = -6

      return copy
    }()

    XCTAssertEqual(mutatedTransform.a, -1)
    XCTAssertEqual(mutatedTransform.b, -2)
    XCTAssertEqual(mutatedTransform.c, -3)
    XCTAssertEqual(mutatedTransform.d, -4)
    XCTAssertEqual(mutatedTransform.tx, -5)
    XCTAssertEqual(mutatedTransform.ty, -6)
  }
}

// MARK: - Vector Transformations

extension CGAffineTransformTest {
  func testVectorTransformations() {
    // To transform a given point with coordinates x and y,
    // we do:
    //
    //                             [ m11  m12  0 ]
    // [ w' h' 1 ] = [ x  y  1 ] * [ m21  m22  0 ]
    //                             [ tx   ty   1 ]
    //
    // [ w' h' 1 ] = [ x*m11+y*m21+1*tX  x*m12+y*m22+1*tY ]

    check(
      point: CGPoint(x: 10, y: 20),
      withTransform: CGAffineTransform(
        a: 1, b: 2,
        c: 3, d: 4,
        tx: 5, ty: 6
      ),

      // [ px*m11+py*m21+tX  px*m12+py*m22+tY ]
      // [   10*1+20*3+5       10*2+20*4+6    ]
      // [       75                106        ]
      mapsTo: CGPoint(x: 75, y: 106)
    )

    check(
      point: CGPoint(x: 5, y: 25),
      withTransform: CGAffineTransform(
        a: 5, b: 4,
        c: 3, d: 2,
        tx: 1, ty: 0
      ),

      // [ px*m11+py*m21+tX  px*m12+py*m22+tY ]
      // [   5*5+25*3+1         5*4+25*2+0    ]
      // [      101                 70        ]
      mapsTo: CGPoint(x: 101, y: 70)
    )
  }
}

// MARK: - Identity

extension CGAffineTransformTest {
  func testIdentityConstruction() {
    // Check that the transform matrix is the identity:
    // [ 1 0 0 ]
    // [ 0 1 0 ]
    // [ 0 0 1 ]
    let identity = CGAffineTransform(
      a: 1, b: 0,
      c: 0, d: 1,
      tx: 0, ty: 0
    )

    XCTAssertEqual(CGAffineTransform(), identity)
    XCTAssertEqual(CGAffineTransform.identity, identity)
  }

  func testIdentity() {
    check(
      point: CGPoint(x: 25, y: 10),
      withTransform: .identity,
      mapsTo: CGPoint(x: 25, y: 10)
    )
  }
}

// MARK: - Translation

extension CGAffineTransformTest {
  func testTranslationConstruction() {
    let translatedIdentity = CGAffineTransform.identity
      .translatedBy(x: 15, y: 20)

    let translation = CGAffineTransform(
      translationX: 15, y: 20
    )

    XCTAssertEqual(translatedIdentity, translation)
  }

  func testTranslation() {
    check(
      point: CGPoint(x: 10, y: 10),
      withTransform: CGAffineTransform(
        translationX: 0, y: 0
      ),
      mapsTo: CGPoint(x: 10, y: 10)
    )

    check(
      point: CGPoint(x: 10, y: 10),
      withTransform: CGAffineTransform(
        translationX: 0, y: 5
      ),
      mapsTo: CGPoint(x: 10, y: 15)
    )

    check(
      point: CGPoint(x: 10, y: 10),
      withTransform: CGAffineTransform(
        translationX: 5, y: 5
      ),
      mapsTo: CGPoint(x: 15, y: 15)
    )

    check(
      point: CGPoint(x: -2, y: -3),
      // Translate by 5
      withTransform: CGAffineTransform.identity
        .translatedBy(x: 2, y: 3)
        .translatedBy(x: 3, y: 2),
      mapsTo: CGPoint(x: 3, y: 2)
    )
  }
}

// MARK: - Scaling

extension CGAffineTransformTest {
  func testScalingConstruction() {
    let scaledIdentity = CGAffineTransform.identity
      .scaledBy(x: 15, y: 20)

    let scaling = CGAffineTransform(
      scaleX: 15, y: 20
    )

    XCTAssertEqual(scaledIdentity, scaling)
  }

  func testScaling() {
    check(
      point: CGPoint(x: 10, y: 10),
      withTransform: CGAffineTransform(
        scaleX: 1, y: 0
      ),
      mapsTo: CGPoint(x: 10, y: 0)
    )

    check(
      point: CGPoint(x: 10, y: 10),
      withTransform: CGAffineTransform(
        scaleX: 0.5, y: 1
      ),
      mapsTo: CGPoint(x: 5, y: 10)
    )

    check(
      point: CGPoint(x: 10, y: 10),
      withTransform: CGAffineTransform(
        scaleX: 0, y: 2
      ),
      mapsTo: CGPoint(x: 0, y: 20)
    )

    check(
      point: CGPoint(x: 10, y: 10),
      // Scale by (2, 0)
      withTransform: CGAffineTransform.identity
        .scaledBy(x: 4, y: 0)
        .scaledBy(x: 0.5, y: 1),
      mapsTo: CGPoint(x: 20, y: 0)
    )
  }
}

// MARK: - Rotation

extension CGAffineTransformTest {
  func testRotationConstruction() {
    let baseRotation = CGAffineTransform(rotationAngle: .pi)

    let point = CGPoint(x: 10, y: 15)
    let expectedPoint = baseRotation.transform(point: point)

    check(
      point: point,
      withTransform: .identity.rotated(by: .pi),
      mapsTo: expectedPoint,
      "Rotation operation on identity doesn't work as identity init."
    )
  }

  func testRotation() {
    check(
      point: CGPoint(x: 10, y: 15),
      withTransform: CGAffineTransform(rotationAngle: 0),
      mapsTo: CGPoint(x: 10, y: 15)
    )

    check(
      point: CGPoint(x: 10, y: 15),
      // Rotate by 3*360º
      withTransform: CGAffineTransform(rotationAngle: .pi * 6),
      mapsTo: CGPoint(x: 10, y: 15)
    )

    // Counter-clockwise rotation
    check(
      point: CGPoint(x: 15, y: 10),
      // Rotate by 90º
      withTransform: CGAffineTransform(rotationAngle: .pi / 2),
      mapsTo: CGPoint(x: -10, y: 15)
    )

    // Clockwise rotation
    check(
      point: CGPoint(x: 15, y: 10),
      // Rotate by -90º
      withTransform: CGAffineTransform(rotationAngle: .pi / -2),
      mapsTo: CGPoint(x: 10, y: -15)
    )

    // Reflect about origin
    check(
      point: CGPoint(x: 10, y: 15),
      // Rotate by 180º
      withTransform: CGAffineTransform(rotationAngle: .pi),
      mapsTo: CGPoint(x: -10, y: -15)
    )

    // Composed reflection about origin
    check(
      point: CGPoint(x: 10, y: 15),
      // Rotate by 180º
      withTransform: CGAffineTransform.identity
        .rotated(by: .pi / 2)
        .rotated(by: .pi / 2),
      mapsTo: CGPoint(x: -10, y: -15)
    )
  }
}

// MARK: - Permutations

extension CGAffineTransformTest {
  func testTranslationScaling() {
    check(
      point: CGPoint(x: 1, y: 3),
      // Translate by (2, 0) then scale by (5, -5)
      withTransform: CGAffineTransform.identity
        .translatedBy(x: 2, y: 0)
        .scaledBy(x: 5, y: -5),
      mapsTo: CGPoint(x: 15, y: -15)
    )

    check(
      point: CGPoint(x: 3, y: 1),
      // Scale by (-5, 5) then scale by (0, 10)
      withTransform: CGAffineTransform.identity
        .scaledBy(x: -5, y: 5)
        .translatedBy(x: 0, y: 10),
      mapsTo: CGPoint(x: -15, y: 15)
    )
  }

  func testTranslationRotation() {
    check(
      point: CGPoint(x: 10, y: 10),
      // Translate by (20, -5) then rotate by 90º
      withTransform: CGAffineTransform.identity
        .translatedBy(x: 20, y: -5)
        .rotated(by: .pi / 2),
      mapsTo: CGPoint(x: -5, y: 30)
    )

    check(
      point: CGPoint(x: 10, y: 10),
      // Rotate by 180º and then translate by (20, 15)
      withTransform: CGAffineTransform.identity
        .rotated(by: .pi)
        .translatedBy(x: 20, y: 15),
      mapsTo: CGPoint(x: 10, y: 5)
    )
  }

  func testScalingRotation() {
    check(
      point: CGPoint(x: 20, y: 5),
      // Scale by (0.5, 3) then rotate by -90º
      withTransform: CGAffineTransform.identity
        .scaledBy(x: 0.5, y: 3)
        .rotated(by: .pi / -2),
      mapsTo: CGPoint(x: 15, y: -10)
    )

    check(
      point: CGPoint(x: 20, y: 5),
      // Rotate by -90º the scale by (0.5, 3)
      withTransform: CGAffineTransform.identity
        .rotated(by: .pi / -2)
        .scaledBy(x: 3, y: -0.5),
      mapsTo: CGPoint(x: 15, y: 10)
    )
  }
}

// MARK: - Inversion

extension CGAffineTransformTest {
  func testInversion() {
    let transforms = [
      CGAffineTransform(translationX: -30, y: 40),
      CGAffineTransform(rotationAngle: .pi / 4),
      CGAffineTransform(scaleX: 20, y: -10),
    ]

    let composeTransform: CGAffineTransform = {
      var transform = CGAffineTransform.identity

      for component in transforms {
        transform = transform.concatenating(component)
      }

      return transform
    }()

    let recoveredIdentity: CGAffineTransform = {
      var transform = composeTransform

      // Append inverse transformations in reverse order
      for component in transforms.reversed() {
        transform = transform.concatenating(
          component.inverted()
        )
      }

      return transform
    }()

    check(
      point: CGPoint(x: 10, y: 10),
      withTransform: recoveredIdentity,
      mapsTo: CGPoint(x: 10, y: 10)
    )
  }
}

// MARK: - Concatenation

extension CGAffineTransformTest {
  func testConcatenation() {
    check(
      point: CGPoint(x: 10, y: 15),
      withTransform: CGAffineTransform.identity
        .concatenating(.identity),
      mapsTo: CGPoint(x: 10, y: 15)
    )

    check(
      point: CGPoint(x: 10, y: 15),
      // Scale by 2 then translate by (10, 0)
      withTransform: CGAffineTransform(scaleX: 2, y: 2)
        .concatenating(CGAffineTransform(
          translationX: 10, y: 0
        )),
      mapsTo: CGPoint(x: 30, y: 30)
    )

    check(
      point: CGPoint(x: 10, y: 15),
      // Translate by (10, 0) then scale by 2
      withTransform: CGAffineTransform(translationX: 10, y: 0)
        .concatenating(CGAffineTransform(scaleX: 2, y: 2)),
      mapsTo: CGPoint(x: 40, y: 30)
    )
  }
}

// MARK: - Coding

extension CGAffineTransformTest {
  func testCoding() throws {
    let transform = CGAffineTransform(
      a: 1, b: 2,
      c: 3, d: 4,
      tx: 5, ty: 6
    )

    let encodedData = try JSONEncoder().encode(transform)

    let encodedString = String(
      data: encodedData, encoding: .utf8
    )

    let commaSeparatedNumbers = (1...6)
      .map(String.init)
      .joined(separator: ",")

    XCTAssertEqual(
      encodedString, "[\(commaSeparatedNumbers)]",
      "Invalid coding representation"
    )

    let recovered = try JSONDecoder().decode(
      CGAffineTransform.self, from: encodedData
    )

    XCTAssertEqual(
      transform, recovered,
      "Encoded and then decoded transform does not equal original"
    )
  }
}
