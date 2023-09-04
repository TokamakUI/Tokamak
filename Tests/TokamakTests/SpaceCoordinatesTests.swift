@testable import TokamakCore
// Copyright 2021 Tokamak contributors
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
import XCTest

final class SpaceCoordinatesTests: XCTestCase {
  func testCoordinateSpaceEquatable() {
    XCTAssertTrue(CoordinateSpace.global == CoordinateSpace.global)
    XCTAssertTrue(CoordinateSpace.local == CoordinateSpace.local)
    XCTAssertFalse(CoordinateSpace.global == CoordinateSpace.local)
  }

  func testCoordinateSpaceHashable() {
    let set: Set<CoordinateSpace> = [.global, .local, .named("custom")]
    XCTAssertEqual(set.count, 3)
  }

  func testIsGlobal() {
    XCTAssertTrue(CoordinateSpace.global.isGlobal)
    XCTAssertFalse(CoordinateSpace.local.isGlobal)
    XCTAssertFalse(CoordinateSpace.named("custom").isGlobal)
  }

  func testIsLocal() {
    XCTAssertTrue(CoordinateSpace.local.isLocal)
    XCTAssertFalse(CoordinateSpace.global.isLocal)
    XCTAssertFalse(CoordinateSpace.named("custom").isLocal)
  }

  func testActiveCoordinateSpaceInitialization() {
    let context = CoordinateSpaceContext()
    XCTAssertTrue(context.activeCoordinateSpace.isEmpty)
  }

  func testActiveCoordinateSpaceUpdate() {
    var context = CoordinateSpaceContext()
    let origin = CGPoint(x: 10, y: 20)
    context.activeCoordinateSpace[.global] = origin

    XCTAssertEqual(context.activeCoordinateSpace[.global], origin)
  }

  func testConvertGlobalSpaceCoordinates() {
    let rect = CGRect(x: 10, y: 20, width: 30, height: 40)
    let namedOrigin = CGPoint(x: 5, y: 10)
    let translatedRect = CoordinateSpace.convertGlobalSpaceCoordinates(
      rect: rect,
      toNamedOrigin: namedOrigin
    )

    XCTAssertEqual(translatedRect.origin, CGPoint(x: 5, y: 10))
    XCTAssertEqual(translatedRect.size, CGSize(width: 30, height: 40))
  }

  func testConvertPointToNamedOrigin() {
    let point = CGPoint(x: 20, y: 30)
    let namedOrigin = CGPoint(x: 5, y: 10)
    let translatedPoint = CoordinateSpace.convert(point, toNamedOrigin: namedOrigin)

    XCTAssertEqual(translatedPoint, CGPoint(x: 15, y: 20))
  }
}
