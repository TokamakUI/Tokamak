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
import TokamakTestRenderer
import XCTest

@_spi(TokamakCore) @testable import TokamakCore

class ViewModifierTests: XCTestCase {
  func testOnReceive() {
    let publisher = PassthroughSubject<String, Never>()
    var receivedValue = ""

    let firstExpectation = XCTestExpectation(description: "First value received from publisher")
    let secondExpectation = XCTestExpectation(description: "Second value received from publisher")

    let contentView = Text("Hello, world!")
      .onReceive(publisher) { value in
        receivedValue = value
        if receivedValue == "Simulate publisher emitting a first value" {
          firstExpectation.fulfill()
        } else if receivedValue == "Simulate publisher emitting a next value" {
          secondExpectation.fulfill()
        }
      }

    XCTAssertEqual(receivedValue, "")
    _ = TestFiberRenderer(.root, size: .zero).render(contentView)

    let fisrPush = "Simulate publisher emitting a first value"
    publisher.send(fisrPush)
    wait(for: [firstExpectation], timeout: 1.0)
    XCTAssertEqual(receivedValue, fisrPush)

    let secondPush = "Simulate publisher emitting a next value"
    publisher.send(secondPush)
    wait(for: [secondExpectation], timeout: 1.0)
    XCTAssertEqual(receivedValue, secondPush)
  }

  func testOnChangeWithValue() {
    var count = 0
    var oldCount = 0

    let contentView = Text("Count: \(count)")
      .onChange(of: count) { newValue, newOldValue in
        count = newValue
        oldCount = newOldValue
      }

    XCTAssertEqual(count, 0)
    XCTAssertEqual(oldCount, 0)

    // Simulate a change in value
    count = 5

    // Re-evaluate the view
    _ = TestFiberRenderer(.root, size: .zero).render(contentView)

    XCTAssertEqual(count, 5)
    XCTAssertEqual(oldCount, 0)
  }

  func testOnChangeWithInitialValue() {
    let count = 0
    var actionFired = false

    let contentView = Text("Hello, world!")
      .onChange(of: count, initial: true) {
        actionFired = true
      }

    XCTAssertFalse(actionFired)

    // Re-evaluate the view
    _ = TestFiberRenderer(.root, size: .zero).render(contentView)

    XCTAssertTrue(actionFired)
  }

  func testModifierComposition() {
    let expectation = XCTestExpectation(description: "")
    let publisher = PassthroughSubject<Int, Never>()
    var receivedValue = 0
    var count = 0

    let contentView = Text("Count: \(count)")
      .onChange(of: count) { newValue, _ in
        count = newValue
      }
      .onReceive(publisher) { value in
        receivedValue = value
        expectation.fulfill()
      }

    XCTAssertEqual(count, 0)
    XCTAssertEqual(receivedValue, 0)
    _ = TestFiberRenderer(.root, size: .zero).render(contentView)

    // Simulate publisher emitting a value
    publisher.send(10)
    // Simulate a change in value
    count = 5

    wait(for: [expectation], timeout: 1.0)
    XCTAssertEqual(count, 5)
    XCTAssertEqual(receivedValue, 10)
  }
}
