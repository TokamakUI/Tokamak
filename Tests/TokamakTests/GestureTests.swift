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

import OpenCombineShim
import XCTest

@_spi(TokamakCore) @testable import TokamakCore

class GestureTests: XCTestCase {
  func testDragGestureBehavior() {
    var gesture = DragGesture()
    var valueDuringChanged: DragGesture.Value?
    var valueDuringEnded: DragGesture.Value?

    // Set onChanged and onEnded actions
    gesture = gesture
      ._onChanged { value in
        valueDuringChanged = value
      }.onEnded { value in
        valueDuringEnded = value
      }.body

    // Simulate a drag gesture
    let startLocation = CGPoint(x: 0, y: 0)
    let changedLocation = CGPoint(x: 50, y: 50)
    let endLocation = CGPoint(x: 100, y: 100)

    var mockContext = _GesturePhaseContext(location: startLocation)

    // Simulate .began phase
    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertEqual(gesture.startLocation, startLocation)
    XCTAssertNil(valueDuringChanged)
    XCTAssertNil(valueDuringEnded)

    // Simulate .changed phase
    mockContext = _GesturePhaseContext(location: changedLocation)
    XCTAssertTrue(gesture._onPhaseChange(.changed(mockContext)))
    XCTAssertEqual(valueDuringChanged?.startLocation, startLocation)
    XCTAssertEqual(valueDuringChanged?.location, changedLocation)
    XCTAssertNil(valueDuringEnded)

    // Simulate .ended phase
    mockContext = _GesturePhaseContext(location: endLocation)
    XCTAssertTrue(gesture._onPhaseChange(.ended(mockContext)))
    XCTAssertNil(gesture.startLocation)
    XCTAssertEqual(valueDuringEnded?.startLocation, startLocation)
    XCTAssertEqual(valueDuringEnded?.location, endLocation)
  }

  func testLongPressGestureBehavior() async throws {
    var gesture = LongPressGesture()
    var valueDuringChanged: Bool?
    var valueDuringEnded: Bool?

    // Set onChanged and onEnded actions
    gesture = gesture
      ._onChanged { value in
        valueDuringChanged = value
      }.onEnded { value in
        valueDuringEnded = value
      }.body

    // Simulate a long press gesture
    let startLocation = CGPoint(x: 0, y: 0)
    let changedLocation = CGPoint(x: 50, y: 50)
    let endLocation = CGPoint(x: 100, y: 100)

    var mockContext = _GesturePhaseContext(location: startLocation)

    // Simulate .began phase
    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertEqual(gesture.startLocation, startLocation)
    XCTAssertNotNil(valueDuringChanged)
    XCTAssertNil(valueDuringEnded)

    // Simulate .changed phase
    mockContext = _GesturePhaseContext(location: changedLocation)
    XCTAssertFalse(gesture._onPhaseChange(.changed(mockContext)))

    let minimumDuration = gesture.minimumDuration + 0.2
    try await Task.sleep(for: .seconds(minimumDuration))

    XCTAssertFalse(gesture._onPhaseChange(.changed(mockContext)))
    XCTAssertTrue(valueDuringChanged == true)
    XCTAssertNil(valueDuringEnded)

    // Simulate .ended phase
    mockContext = _GesturePhaseContext(location: endLocation)
    XCTAssertFalse(gesture._onPhaseChange(.ended(mockContext)))
    XCTAssertNil(gesture.startLocation)
  }

  func testSingleTapGesture() {
    var gesture = TapGesture(count: 1)
    var valueDuringEnded = false
    gesture = gesture
      .onEnded {
        valueDuringEnded = true
      }.body

    let mockContext = _GesturePhaseContext()
    // Simulate a single tap gesture
    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertTrue(gesture._onPhaseChange(.ended(mockContext)))
    XCTAssertTrue(valueDuringEnded)

    // Simulate a cancelled tap gesture
    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertFalse(gesture._onPhaseChange(.cancelled))
  }

  func testDoubleTapGesture() async throws {
    var gesture = TapGesture(count: 2)
    var valueDuringEnded = 0
    gesture = gesture
      .onEnded {
        valueDuringEnded += 1
      }.body

    let mockContext = _GesturePhaseContext()
    // Simulate a double tap gesture
    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertFalse(gesture._onPhaseChange(.ended(mockContext)))

    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertTrue(gesture._onPhaseChange(.ended(mockContext)))
    XCTAssertEqual(valueDuringEnded, 1) // Double tap completed

    try await Task.sleep(for: .seconds(0.4))
    // Simulate a triple tap gesture
    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertFalse(gesture._onPhaseChange(.ended(mockContext)))
    XCTAssertEqual(valueDuringEnded, 1)

    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertTrue(gesture._onPhaseChange(.ended(mockContext)))
    XCTAssertEqual(valueDuringEnded, 2)

    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertFalse(gesture._onPhaseChange(.ended(mockContext)))
    XCTAssertEqual(valueDuringEnded, 2) // Triple tap completed
  }

  func testCancelledTapGesture() async throws {
    var gesture = TapGesture(count: 2)
    var valueDuringEnded = 0
    gesture = gesture
      .onEnded {
        valueDuringEnded += 1
      }.body

    let mockContext = _GesturePhaseContext()

    // Simulate a double tap gesture
    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertFalse(gesture._onPhaseChange(.ended(mockContext)))
    XCTAssertEqual(valueDuringEnded, 0) // Double tap not completed yet

    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertFalse(gesture._onPhaseChange(.cancelled))
    XCTAssertEqual(valueDuringEnded, 0) // Double tap cancelled

    try await Task.sleep(for: .seconds(0.4))
    // Simulate a single tap gesture after cancellation
    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertFalse(gesture._onPhaseChange(.ended(mockContext)))
    XCTAssertEqual(valueDuringEnded, 0) // Single tap after cancellation

    try await Task.sleep(for: .seconds(0.4))
    // Simulate a double tap gesture again
    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertFalse(gesture._onPhaseChange(.ended(mockContext)))
    XCTAssertEqual(valueDuringEnded, 0) // Double tap not completed yet

    XCTAssertFalse(gesture._onPhaseChange(.began(mockContext)))
    XCTAssertFalse(gesture._onPhaseChange(.ended(mockContext)))
    XCTAssertEqual(valueDuringEnded, 0) // Double tap completed
  }
}
