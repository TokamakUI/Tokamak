// Copyright 2023 Tokamak contributors
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
//  Created by Lukas Stabe on 09/02/23.
//

import XCTest

@_spi(TokamakCore) @testable import TokamakCore
import TokamakTestRenderer

final class AppearanceActionTests: XCTestCase {
  static var appearACalled = 0
  static var appearBCalled = 0
  static var disappearACalled = 0
  static var disappearBCalled = 0

  override func setUp() {
    Self.appearACalled = 0
    Self.appearBCalled = 0
    Self.disappearACalled = 0
    Self.disappearBCalled = 0
  }

  func testAppearDisappearInCondition() {
    struct Test: View {
      @State var show = false
      var body: some View {
        Text("a")
          .onAppear { AppearanceActionTests.appearACalled += 1 }
          .onDisappear { AppearanceActionTests.disappearACalled += 1 }
        if show {
          Text("b")
            .onAppear { AppearanceActionTests.appearBCalled += 1 }
            .onDisappear { AppearanceActionTests.disappearBCalled += 1 }
        }
        Button("show") { show.toggle() }.identified(by: "show")
      }
    }

    let reconciler = TestFiberRenderer(.root, size: .zero).render(Test())

    XCTAssert(Self.appearACalled == 1)
    XCTAssert(Self.appearBCalled == 0)
    XCTAssert(Self.disappearACalled == 0)
    XCTAssert(Self.disappearBCalled == 0)

    reconciler.findView(id: "show").tap()

    XCTAssert(Self.appearACalled == 1)
    XCTAssert(Self.appearBCalled == 1)
    XCTAssert(Self.disappearACalled == 0)
    XCTAssert(Self.disappearBCalled == 0)

    reconciler.findView(id: "show").tap()

    XCTAssert(Self.appearACalled == 1)
    XCTAssert(Self.appearBCalled == 1)
    XCTAssert(Self.disappearACalled == 0)
    XCTAssert(Self.disappearBCalled == 1)

    reconciler.findView(id: "show").tap()

    XCTAssert(Self.appearACalled == 1)
    XCTAssert(Self.appearBCalled == 2)
    XCTAssert(Self.disappearACalled == 0)
    XCTAssert(Self.disappearBCalled == 1)
  }

  func testChangingIdCallsActions() {
    struct Root: View {
      @State var reverse: Bool = true
      var body: some View {
        let items = reverse ? ["b", "a", "c"] : ["a", "b", "c"]
        ForEach(0..<3) { i in
          Text("\(items[i])")
            .onAppear { AppearanceActionTests.appearACalled += 1 }
            .onDisappear { AppearanceActionTests.disappearACalled += 1 }
            .id(items[i])
        }
        Button("flip") { reverse.toggle() }.identified(by: "flip")
      }
    }

    let reconciler = TestFiberRenderer(.root, size: .zero).render(Root())

    XCTAssert(Self.appearACalled == 3)
    XCTAssert(Self.disappearACalled == 0)

    reconciler.findView(id: "flip").tap()

    XCTAssert(Self.appearACalled == 5)
    XCTAssert(Self.disappearACalled == 2)
  }
}
