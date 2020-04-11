//
//  TestRenderer.swift
//  TokamakTestRenderer
//
//  Created by Max Desiatov on 07/12/2018.
//

import TokamakDemo
import TokamakTestRenderer
import XCTest

@testable import Tokamak

final class ReconcilerTests: XCTestCase {
  func testMount() {
    let renderer = TestRenderer(Counter(42))
    let root = renderer.rootTarget

    XCTAssertTrue(root.view.view is EmptyView)
    XCTAssertEqual(root.subviews.count, 1)
    let stack = root.subviews[0]
    XCTAssertTrue(stack.view.view is HStack<TupleView<(Button<Text>, Text)>>)
    XCTAssertEqual(stack.subviews.count, 2)
    XCTAssertTrue(stack.subviews[0].view.view is Button<Text>)
    XCTAssertTrue(stack.subviews[1].view.view is Text)
    XCTAssertEqual((stack.subviews[1].view.view as? Text)?.content, "42")
  }

  func testUpdate() {
    let renderer = TestRenderer(Counter(42))
    let root = renderer.rootTarget
    let stack = root.subviews[0]

    guard let button = stack.subviews[0].view.view as? Button<Text> else {
      XCTAssert(false, "counter has no button")
      return
    }

    let originalLabel = stack.subviews[1]

    button.action()

    let e = expectation(description: "rerender")

    DispatchQueue.main.async {
      XCTAssertTrue(root.view.view is EmptyView)
      XCTAssertEqual(root.subviews.count, 1)
      let newStack = root.subviews[0]
      XCTAssert(stack === newStack)
      XCTAssertTrue(stack.view.view is HStack<TupleView<(Button<Text>, Text)>>)
      XCTAssertEqual(stack.subviews.count, 2)
      XCTAssertTrue(stack.subviews[0].view.view is Button<Text>)
      XCTAssertTrue(stack.subviews[1].view.view is Text)
      XCTAssertTrue(originalLabel === newStack.subviews[1])
      XCTAssertEqual((stack.subviews[1].view.view as? Text)?.content, "43")

      e.fulfill()
    }

    wait(for: [e], timeout: 30)
  }

  func testDoubleUpdate() {
    let renderer = TestRenderer(Counter(42))
    let root = renderer.rootTarget
    let stack = root.subviews[0]

    guard let button = stack.subviews[0].view.view as? Button<Text> else {
      XCTAssert(false, "counter has no button")
      return
    }

    let originalLabel = stack.subviews[1]

    button.action()

    let e = expectation(description: "rerender")

    DispatchQueue.main.async {
      XCTAssertTrue(root.view.view is EmptyView)
      XCTAssertEqual(root.subviews.count, 1)
      let newStack = root.subviews[0]
      XCTAssert(stack === newStack)
      XCTAssertTrue(stack.view.view is HStack<TupleView<(Button<Text>, Text)>>)
      XCTAssertEqual(stack.subviews.count, 2)
      XCTAssertTrue(stack.subviews[0].view.view is Button<Text>)
      XCTAssertTrue(stack.subviews[1].view.view is Text)
      XCTAssertTrue(originalLabel === newStack.subviews[1])
      XCTAssertEqual((stack.subviews[1].view.view as? Text)?.content, "43")

      guard let button = stack.subviews[0].view.view as? Button<Text> else {
        XCTAssert(false, "counter has no button")
        return
      }

      button.action()

      DispatchQueue.main.async {
        XCTAssertTrue(root.view.view is EmptyView)
        XCTAssertEqual(root.subviews.count, 1)
        let newStack = root.subviews[0]
        XCTAssert(stack === newStack)
        XCTAssertTrue(stack.view.view is HStack<TupleView<(Button<Text>, Text)>>)
        XCTAssertEqual(stack.subviews.count, 2)
        XCTAssertTrue(stack.subviews[0].view.view is Button<Text>)
        XCTAssertTrue(stack.subviews[1].view.view is Text)
        XCTAssertTrue(originalLabel === newStack.subviews[1])
        XCTAssertEqual((stack.subviews[1].view.view as? Text)?.content, "44")

        e.fulfill()
      }
    }

    wait(for: [e], timeout: 1)
  }

  func testUnmount() {
    let renderer = TestRenderer(Counter(42, limit: 45))
    let root = renderer.rootTarget

    let stack = root.subviews[0]
    guard let button = stack.subviews[0].view.view as? Button<Text> else {
      XCTAssert(false, "counter has no button")
      return
    }

    button.action()

    let e = expectation(description: "rerender")

    DispatchQueue.main.async {
      // rerender completed here, schedule another one
      guard let button = stack.subviews[0].view.view as? Button<Text> else {
        XCTAssert(false, "counter has no button")
        return
      }

      button.action()

      DispatchQueue.main.async {
        guard let button = stack.subviews[0].view.view as? Button<Text> else {
          XCTAssert(false, "counter has no button")
          return
        }

        button.action()

        DispatchQueue.main.async {
          XCTAssertTrue(root.view.view is EmptyView)
          XCTAssertEqual(root.subviews.count, 1)
          let newStack = root.subviews[0]
          XCTAssert(stack === newStack)
          XCTAssertTrue(stack.view.view is HStack<EmptyView>)
          XCTAssertEqual(stack.subviews.count, 0)

          e.fulfill()
        }
      }
    }

    wait(for: [e], timeout: 1)
  }
}
