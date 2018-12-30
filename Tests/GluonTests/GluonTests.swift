//
//  TestRenderer.swift
//  GluonTestRenderer
//
//  Created by Max Desiatov on 07/12/2018.
//

import GluonTestRenderer
import XCTest

@testable import Gluon

struct Counter: LeafComponent {
  typealias Props = Int

  static func render(props: Int) -> Node {
    let (count, setCount) = hooks.state(props)
    let (sliding, setSliding) = hooks.state(0.5 as Float)

    let children = count < 44 ? [
      Button.node(.init(handlers: [
        .touchUpInside: Handler { setCount(count + 1) },
        ]), "Increment"),

      Label.node(Null(), "\(count)"),

      Slider.node(Slider.Props(
        value: sliding, valueHandler: Handler { setSliding($0) }
      )),

      Label.node(Null(), "\(sliding)"),
    ] : []

    return StackView.node(.init(axis: .vertical,
                                distribution: .fillEqually,
                                frame: .zero),
                          children)
  }
}

final class GluonTests: XCTestCase {
  func testMount() {
    let renderer = TestRenderer(Counter.node(42))

    guard let root = renderer.rootTarget else {
      XCTAssert(false, "TestRenderer got no root target")
      return
    }

    XCTAssert(root.component == View.self)
    XCTAssertEqual(root.subviews.count, 1)
    let stack = root.subviews[0]
    XCTAssert(stack.component == StackView.self)
    XCTAssert(type(of: stack.props.value) == StackView.Props.self)
    XCTAssertEqual(stack.subviews.count, 4)
    XCTAssert(stack.subviews[0].component == Button.self)
    XCTAssert(stack.subviews[1].component == Label.self)
    XCTAssertEqual(stack.subviews[1].children, AnyEquatable("42"))
  }

  func testUpdate() {
    let renderer = TestRenderer(Counter.node(42))

    guard let root = renderer.rootTarget,
      let props = root.subviews[0].subviews[0]
      .props.value as? Button.Props else {
      XCTAssert(false, "button component got wrong props types")
      return
    }

    guard let handler = props.handlers[.touchUpInside]?.value else {
      XCTAssert(false, "button component got no handler")
      return
    }

    let originalStack = root.subviews[0]
    let originalLabel = originalStack.subviews[1]

    handler(())

    let e = expectation(description: "rerender")

    DispatchQueue.main.async {
      XCTAssert(root.component == View.self)
      XCTAssertEqual(root.subviews.count, 1)
      let newStack = root.subviews[0]
      XCTAssert(originalStack === newStack)
      XCTAssert(newStack.component == StackView.self)
      XCTAssert(type(of: newStack.props.value) == StackView.Props.self)
      XCTAssertEqual(newStack.subviews.count, 4)
      XCTAssert(newStack.subviews[0].component == Button.self)
      XCTAssert(newStack.subviews[1].component == Label.self)
      XCTAssert(originalLabel === newStack.subviews[1])
      XCTAssertEqual(newStack.subviews[1].children, AnyEquatable("43"))

      e.fulfill()
    }

    wait(for: [e], timeout: 1)
  }

  func testUnmount() {
    let renderer = TestRenderer(Counter.node(42))

    guard let root = renderer.rootTarget,
      let props = root.subviews[0].subviews[0]
      .props.value as? Button.Props else {
      XCTAssert(false, "button component got wrong props types")
      return
    }

    guard let handler = props.handlers[.touchUpInside]?.value else {
      XCTAssert(false, "button component got no handler")
      return
    }

    handler(())

    let e = expectation(description: "rerender")

    DispatchQueue.main.async {
      // rerender completed here, schedule another one

      guard let root = renderer.rootTarget,
        let props = root.subviews[0].subviews[0]
        .props.value as? Button.Props else {
        XCTAssert(false, "button component got wrong props types")
        return
      }

      guard let handler = props.handlers[.touchUpInside]?.value else {
        XCTAssert(false, "button component got no handler")
        return
      }

      handler(())

      DispatchQueue.main.async {
        XCTAssert(root.component == View.self)
        XCTAssertEqual(root.subviews.count, 1)
        let stack = root.subviews[0]
        XCTAssert(stack.component == StackView.self)
        XCTAssert(type(of: stack.props.value) == StackView.Props.self)
        XCTAssertEqual(stack.subviews.count, 0)

        e.fulfill()
      }
    }

    wait(for: [e], timeout: 1)
  }

  static var allTests = [
    ("testMount", testMount),
  ]
}
