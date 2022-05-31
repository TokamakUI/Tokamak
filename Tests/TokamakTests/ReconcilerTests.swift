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
//  Created by Max Desiatov on 07/12/2018.
//

@_spi(TokamakCore) import TokamakTestRenderer
import XCTest

@testable import TokamakCore

private struct Counter: View {
  @State
  var count: Int

  let limit: Int

  public var body: some View {
    if count < limit {
      VStack {
        Button("Increment") { count += 1 }
        Text("\(count)")
      }
    } else {
      VStack { Text("Limit exceeded") }
    }
  }
}

private extension Text {
  var verbatim: String? {
    guard case let .verbatim(text) = storage else { return nil }
    return text
  }
}

final class ReconcilerTests: XCTestCase {
  func testMount() {
    let renderer = TestRenderer(Counter(count: 42, limit: 45))
    let root = renderer.rootTarget

    XCTAssertTrue(root.view.view is EmptyView)
    XCTAssertEqual(root.subviews.count, 1)
    let conditional = root.subviews[0]
    XCTAssertTrue(
      conditional.view.view is
        _ConditionalContent<VStack<TupleView<(Button<Text>, Text)>>, VStack<Text>>
    )
    let stack = conditional.subviews[0]
    XCTAssertEqual(stack.subviews.count, 2)
    XCTAssertTrue(stack.subviews[0].view.view is Button<Text>.Body)
    XCTAssertTrue(stack.subviews[1].view.view is Text)
    XCTAssertEqual((stack.subviews[1].view.view as? Text)?.verbatim, "42")
  }

  func testUpdate() {
    let renderer = TestRenderer(Counter(count: 42, limit: 45))
    let root = renderer.rootTarget
    let stack = root.subviews[0].subviews[0]

    guard let button = stack.subviews[0].subviews[0].view
      .view as? _PrimitiveButtonStyleBody<PrimitiveButtonStyleConfiguration.Label>
    else {
      XCTAssert(false, "counter has no button")
      return
    }

    let originalLabel = stack.subviews[1]

    button.action()

    XCTAssertTrue(root.view.view is EmptyView)
    XCTAssertEqual(root.subviews.count, 1)
    let newStack = root.subviews[0].subviews[0]
    XCTAssert(stack === newStack)
    XCTAssertTrue(stack.view.view is VStack<TupleView<(Button<Text>, Text)>>)
    XCTAssertEqual(stack.subviews.count, 2)
    XCTAssertTrue(stack.subviews[0].view.view is Button<Text>.Body)
    XCTAssertTrue(stack.subviews[1].view.view is Text)
    XCTAssertTrue(originalLabel === newStack.subviews[1])
    XCTAssertEqual((stack.subviews[1].view.view as? Text)?.verbatim, "43")
  }

  func testDoubleUpdate() {
    let renderer = TestRenderer(Counter(count: 42, limit: 45))
    let root = renderer.rootTarget
    let stack = root.subviews[0].subviews[0]

    guard let button = stack.subviews[0].subviews[0].view
      .view as? _PrimitiveButtonStyleBody<PrimitiveButtonStyleConfiguration.Label>
    else {
      XCTAssert(false, "counter has no button")
      return
    }

    let originalLabel = stack.subviews[1]

    button.action()

    XCTAssertTrue(root.view.view is EmptyView)
    XCTAssertEqual(root.subviews.count, 1)
    let newStack = root.subviews[0].subviews[0]
    XCTAssert(stack === newStack)
    XCTAssertTrue(stack.view.view is VStack<TupleView<(Button<Text>, Text)>>)
    XCTAssertEqual(stack.subviews.count, 2)
    XCTAssertTrue(stack.subviews[0].view.view is Button<Text>.Body)
    XCTAssertTrue(stack.subviews[1].view.view is Text)
    XCTAssertTrue(originalLabel === newStack.subviews[1])
    XCTAssertEqual((stack.subviews[1].view.view as? Text)?.verbatim, "43")

    guard let newButton = stack.subviews[0].subviews[0].view
      .view as? _PrimitiveButtonStyleBody<PrimitiveButtonStyleConfiguration.Label>
    else {
      XCTAssert(false, "counter has no button")
      return
    }

    newButton.action()

    XCTAssertTrue(root.view.view is EmptyView)
    XCTAssertEqual(root.subviews.count, 1)
    let newestStack = root.subviews[0].subviews[0]
    XCTAssert(stack === newestStack)
    XCTAssertTrue(stack.view.view is VStack<TupleView<(Button<Text>, Text)>>)
    XCTAssertEqual(stack.subviews.count, 2)
    XCTAssertTrue(stack.subviews[0].view.view is Button<Text>.Body)
    XCTAssertTrue(stack.subviews[1].view.view is Text)
    XCTAssertTrue(originalLabel === newStack.subviews[1])
    XCTAssertEqual((stack.subviews[1].view.view as? Text)?.verbatim, "44")
  }

  func testUnmount() {
    let renderer = TestRenderer(Counter(count: 42, limit: 45))
    let root = renderer.rootTarget

    let stack = root.subviews[0].subviews[0]
    guard let button = stack.subviews[0].subviews[0].view
      .view as? _PrimitiveButtonStyleBody<PrimitiveButtonStyleConfiguration.Label>
    else {
      XCTAssert(false, "counter has no button")
      return
    }

    button.action()

    guard let newButton = stack.subviews[0].subviews[0].view
      .view as? _PrimitiveButtonStyleBody<PrimitiveButtonStyleConfiguration.Label>
    else {
      XCTAssert(false, "counter has no button")
      return
    }

    newButton.action()

    guard let newestButton = stack.subviews[0].subviews[0].view
      .view as? _PrimitiveButtonStyleBody<PrimitiveButtonStyleConfiguration.Label>
    else {
      XCTAssert(false, "counter has no button")
      return
    }

    newestButton.action()

    XCTAssertTrue(root.view.view is EmptyView)
    XCTAssertEqual(root.subviews.count, 1)
    let newStack = root.subviews[0].subviews[0]
    XCTAssert(stack === newStack)
    XCTAssertTrue(stack.view.view is VStack<Text>)
    XCTAssertEqual(stack.subviews.count, 1)
  }
}
