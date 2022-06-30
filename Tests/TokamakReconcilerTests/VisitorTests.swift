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
//  Created by Carson Katri on 2/3/22.
//

import XCTest

@_spi(TokamakCore) @testable import TokamakCore
import TokamakTestRenderer

final class VisitorTests: XCTestCase {
  func testCounter() {
    struct TestView: View {
      struct Counter: View {
        @State
        private var count = 0

        var body: some View {
          VStack {
            Text("\(count)")
              .identified(by: "count")
            HStack {
              if count > 0 {
                Button("Decrement") {
                  count -= 1
                }
                .identified(by: "decrement")
              }
              if count < 5 {
                Button("Increment") {
                  count += 1
                }
                .identified(by: "increment")
              }
            }
          }
        }
      }

      public var body: some View {
        Counter()
      }
    }
    let reconciler = TestFiberRenderer(.root, size: .zero).render(TestView())

    let incrementButton = reconciler.findView(id: "increment", as: Button<Text>.self)
    let countText = reconciler.findView(id: "count", as: Text.self)
    let decrementButton = reconciler.findView(id: "decrement", as: Button<Text>.self)
    // The decrement button is removed when count is < 0
    XCTAssertNil(decrementButton.view, "'Decrement' should be hidden when count <= 0")
    XCTAssertNotNil(incrementButton.view, "'Increment' should be visible when count < 5")
    // Count up to 5
    for i in 0..<5 {
      XCTAssertEqual(countText.view, Text("\(i)"))
      incrementButton.action?()
    }
    XCTAssertNil(incrementButton.view, "'Increment' should be hidden when count >= 5")
    XCTAssertNotNil(decrementButton.view, "'Decrement' should be visible when count > 0")
    // Count down to 0.
    for i in 0..<5 {
      XCTAssertEqual(countText.view, Text("\(5 - i)"))
      decrementButton.action?()
    }
    XCTAssertNil(decrementButton.view, "'Decrement' should be hidden when count <= 0")
    XCTAssertNotNil(incrementButton.view, "'Increment' should be visible when count < 5")
  }

  func testForEach() {
    struct TestView: View {
      @State
      private var count = 0

      var body: some View {
        VStack {
          Button("Add Item") { count += 1 }
            .identified(by: "addItem")
          ForEach(Array(0..<count), id: \.self) { i in
            Text("Item \(i)")
              .identified(by: i)
          }
        }
      }
    }

    let reconciler = TestFiberRenderer(.root, size: .zero).render(TestView())

    let addItemButton = reconciler.findView(id: "addItem", as: Button<Text>.self)
    XCTAssertNotNil(addItemButton)
    for i in 0..<10 {
      addItemButton.action?()
      XCTAssertEqual(reconciler.findView(id: i).view, Text("Item \(i)"))
    }
  }

  func testDynamicProperties() {
    enum DynamicPropertyTest: Hashable {
      case state
      case environment
      case stateObject
      case observedObject
      case environmentObject
    }
    struct TestView: View {
      var body: some View {
        TestState()
        TestEnvironment()
        TestStateObject()
      }

      struct TestState: View {
        @State
        private var count = 0

        var body: some View {
          Button("\(count)") { count += 1 }
            .identified(by: DynamicPropertyTest.state)
        }
      }

      private enum TestKey: EnvironmentKey {
        static let defaultValue = 5
      }

      struct TestEnvironment: View {
        @Environment(\.self)
        var values

        var body: some View {
          Text("\(values[TestKey.self])")
            .identified(by: DynamicPropertyTest.environment)
        }
      }

      struct TestStateObject: View {
        final class Count: ObservableObject {
          @Published
          var count = 0

          func increment() {
            count += 5
          }
        }

        @StateObject
        private var count = Count()

        var body: some View {
          VStack {
            Button("\(count.count)") {
              count.increment()
            }
            .identified(by: DynamicPropertyTest.stateObject)
            TestObservedObject(count: count)
            TestEnvironmentObject()
          }
          .environmentObject(count)
        }

        struct TestObservedObject: View {
          @ObservedObject
          var count: Count

          var body: some View {
            Text("\(count.count)")
              .identified(by: DynamicPropertyTest.observedObject)
          }
        }

        struct TestEnvironmentObject: View {
          @EnvironmentObject
          var count: Count

          var body: some View {
            Text("\(count.count)")
              .identified(by: DynamicPropertyTest.environmentObject)
          }
        }
      }
    }

    let reconciler = TestFiberRenderer(.root, size: .zero).render(TestView())

    // State
    let button = reconciler.findView(id: DynamicPropertyTest.state, as: Button<Text>.self)
    XCTAssertEqual(button.label, Text("0"))
    button.action?()
    XCTAssertEqual(button.label, Text("1"))

    // Environment
    XCTAssertEqual(
      reconciler.findView(id: DynamicPropertyTest.environment).view,
      Text("5")
    )

    // StateObject
    let stateObjectButton = reconciler.findView(
      id: DynamicPropertyTest.stateObject,
      as: Button<Text>.self
    )
    XCTAssertEqual(stateObjectButton.label, Text("0"))
    stateObjectButton.action?()
    stateObjectButton.action?()
    XCTAssertEqual(stateObjectButton.label, Text("5"))

    XCTAssertEqual(
      reconciler.findView(id: DynamicPropertyTest.observedObject).view,
      Text("5")
    )

    XCTAssertEqual(
      reconciler.findView(id: DynamicPropertyTest.environmentObject).view,
      Text("5")
    )
  }
}
