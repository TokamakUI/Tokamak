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

extension FiberReconciler {
  /// Expect a `Fiber` to represent a particular `View` type.
  func expect<V>(
    _ fiber: Fiber?,
    represents viewType: V.Type,
    _ message: String? = nil
  ) where V: View {
    guard case let .view(view, _) = fiber?.content else {
      return XCTAssert(false, "Fiber does not exit")
    }
    if let message = message {
      XCTAssert(type(of: view) == viewType, message)
    } else {
      XCTAssert(type(of: view) == viewType)
    }
  }

  /// Expect a `Fiber` to represent a `View` matching`testView`.
  func expect<V>(
    _ fiber: Fiber?,
    equals testView: V,
    _ message: String? = nil
  ) where V: View & Equatable {
    guard case let .view(fiberView, _) = fiber?.content else {
      return XCTAssert(false, "Fiber does not exit")
    }
    if let message = message {
      XCTAssertEqual(fiberView as? V, testView, message)
    } else {
      XCTAssertEqual(fiberView as? V, testView)
    }
  }
}

final class VisitorTests: XCTestCase {
  func testCounter() {
    struct TestView: View {
      struct Counter: View {
        @State
        private var count = 0

        var body: some View {
          VStack {
            Text("\(count)")
            HStack {
              if count > 0 {
                Button("Decrement") {
                  count -= 1
                }
              }
              if count < 5 {
                Button("Increment") {
                  count += 1
                }
              }
            }
          }
        }
      }

      public var body: some View {
        Counter()
      }
    }
    let reconciler = TestFiberRenderer(.root, size: .init(width: 500, height: 500))
      .render(TestView())
    var hStack: FiberReconciler<TestFiberRenderer>.Fiber? {
      reconciler.current // RootView
        .child? // LayoutView
        .child? // ModifiedContent
        .child? // _ViewModifier_Content
        .child? // TestView
        .child? // Counter
        .child? // VStack
        .child? // TupleView
        .child?.sibling? // HStack
        .child // TupleView
    }
    var text: FiberReconciler<TestFiberRenderer>.Fiber? {
      reconciler.current // RootView
        .child? // LayoutView
        .child? // ModifiedContent
        .child? // _ViewModifier_Content
        .child? // TestView
        .child? // Counter
        .child? // VStack
        .child? // TupleView
        .child // Text
    }
    var decrementButton: FiberReconciler<TestFiberRenderer>.Fiber? {
      hStack?
        .child? // Optional
        .child // Button
    }
    var incrementButton: FiberReconciler<TestFiberRenderer>.Fiber? {
      hStack?
        .child?.sibling? // Optional
        .child // Button
    }
    func decrement() {
      guard case let .view(view, _) = decrementButton?.content
      else { return }
      (view as? Button<Text>)?.action()
    }
    func increment() {
      guard case let .view(view, _) = incrementButton?.content
      else { return }
      (view as? Button<Text>)?.action()
    }
    // The decrement button is removed when count is < 0
    XCTAssertNil(decrementButton, "'Decrement' should be hidden when count <= 0")
    // Count up to 5
    for i in 0..<5 {
      reconciler.expect(text, equals: Text("\(i)"))
      increment()
    }
    XCTAssertNil(incrementButton, "'Increment' should be hidden when count >= 5")
    reconciler.expect(
      decrementButton,
      represents: Button<Text>.self,
      "'Decrement' should be visible when count > 0"
    )
    // Count down to 0.
    for i in 0..<5 {
      reconciler.expect(text, equals: Text("\(5 - i)"))
      decrement()
    }
    XCTAssertNil(decrementButton, "'Decrement' should be hidden when count <= 0")
    reconciler.expect(
      incrementButton,
      represents: Button<Text>.self,
      "'Increment' should be visible when count < 5"
    )
  }

  func testForEach() {
    struct TestView: View {
      @State
      private var count = 0

      var body: some View {
        VStack {
          Button("Add Item") { count += 1 }
          ForEach(Array(0..<count), id: \.self) { i in
            Text("Item \(i)")
          }
        }
      }
    }

    let reconciler = TestFiberRenderer(
      .root,
      size: .init(width: 500, height: 500),
      useDynamicLayout: true
    )
    .render(TestView())
    var addItemFiber: FiberReconciler<TestFiberRenderer>.Fiber? {
      reconciler.current // RootView
        .child? // LayoutView
        .child? // ModifiedContent
        .child? // _ViewModifier_Content
        .child? // TestView
        .child? // VStack
        .child? // TupleView
        .child // Button
    }
    var forEachFiber: FiberReconciler<TestFiberRenderer>.Fiber? {
      reconciler.current // RootView
        .child? // LayoutView
        .child? // ModifiedContent
        .child? // _ViewModifier_Content
        .child? // TestView
        .child? // VStack
        .child? // TupleView
        .child?.sibling // ForEach
    }
    func item(at index: Int) -> FiberReconciler<TestFiberRenderer>.Fiber? {
      var node = forEachFiber?.child
      for _ in 0..<index {
        node = node?.sibling
      }
      return node
    }
    func addItem() {
      guard case let .view(view, _) = addItemFiber?.content
      else { return }
      (view as? Button<Text>)?.action()
    }
    reconciler.expect(addItemFiber, represents: Button<Text>.self)
    reconciler.expect(forEachFiber, represents: ForEach<[Int], Int, Text>.self)
    addItem()
    reconciler.expect(item(at: 0), equals: Text("Item 0"))
    XCTAssertEqual(reconciler.renderer.rootElement.children[0].children.count, 2)
    addItem()
    reconciler.expect(item(at: 1), equals: Text("Item 1"))
    XCTAssertEqual(reconciler.renderer.rootElement.children[0].children.count, 3)
    addItem()
    reconciler.expect(item(at: 2), equals: Text("Item 2"))
    XCTAssertEqual(reconciler.renderer.rootElement.children[0].children.count, 4)
  }
}
