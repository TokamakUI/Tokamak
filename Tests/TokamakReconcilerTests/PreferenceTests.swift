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
//
//  Created by Carson Katri on 6/29/22.
//

import XCTest

@_spi(TokamakCore) @testable import TokamakCore
import TokamakTestRenderer

private enum TestKey: PreferenceKey {
  static let defaultValue: Int = 0
  static func reduce(value: inout Int, nextValue: () -> Int) {
    value += nextValue()
  }
}

final class PreferenceTests: XCTestCase {
  func testPreferenceAction() {
    struct TestView: View {
      public var body: some View {
        Text("")
          .preference(key: TestKey.self, value: 2)
          .preference(key: TestKey.self, value: 3)
          .onPreferenceChange(TestKey.self) {
            XCTAssertEqual($0, 5)
          }
      }
    }
    let reconciler = TestFiberRenderer(.root, size: .init(width: 500, height: 500))
      .render(TestView())
    reconciler.fiberChanged(reconciler.current)
  }

  func testOverlay() {
    struct TestView: View {
      var body: some View {
        Text("")
          .preference(key: TestKey.self, value: 2)
          .preference(key: TestKey.self, value: 3)
          .overlayPreferenceValue(TestKey.self) {
            Text("\($0)")
              .identified(by: "overlay")
          }
      }
    }

    let reconciler = TestFiberRenderer(.root, size: .init(width: 500, height: 500))
      .render(TestView())

    XCTAssertEqual(reconciler.findView(id: "overlay").view, Text("5"))
  }
}
