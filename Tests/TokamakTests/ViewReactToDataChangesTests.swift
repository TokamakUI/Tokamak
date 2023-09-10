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

    let contentView = Text("Hello, world!")
      .onReceive(publisher) { value in
        receivedValue = value
      }

    XCTAssertEqual(receivedValue, "")

    // Simulate publisher emitting a value
    publisher.send("Testing onReceive")
    XCTAssertEqual(receivedValue, "Testing onReceive")

    // Simulate publisher emitting a value
    publisher.send("Second onReceive")
    XCTAssertEqual(receivedValue, "Second onReceive")
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
    let reconciler = TestFiberRenderer(.root, size: .zero).render(contentView)

    XCTAssertEqual(count, 5)
    XCTAssertEqual(oldCount, 0)
  }

  func testOnChangeWithInitialValue() {
    var count = 0
    var actionFired = false

    let contentView = Text("Hello, world!")
      .onChange(of: count, initial: true) {
        actionFired = true
      }

    XCTAssertFalse(actionFired)

    // Re-evaluate the view
    let reconciler = TestFiberRenderer(.root, size: .zero).render(contentView)

    XCTAssertTrue(actionFired)
  }

  func testModifierComposition() {
    let publisher = PassthroughSubject<Int, Never>()
    var receivedValue = 0
    var count = 0

    let contentView = Text("Count: \(count)")
      .onChange(of: count) { newValue, _ in
        count = newValue
      }
      .onReceive(publisher) { value in
        receivedValue = value
      }

    XCTAssertEqual(count, 0)
    XCTAssertEqual(receivedValue, 0)

    // Simulate publisher emitting a value
    publisher.send(10)
    // Simulate a change in value
    count = 5

    // Re-evaluate the view
    let reconciler = TestFiberRenderer(.root, size: .zero).render(contentView)

    XCTAssertEqual(count, 5)
    XCTAssertEqual(receivedValue, 10)
  }
}
