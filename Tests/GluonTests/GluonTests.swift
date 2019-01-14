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

  static func render(props: Int, hooks: Hooks) -> AnyNode {
    let count = hooks.state(props)
    let sliding = hooks.state(0.5 as Float)

    let children = count.value < 45 ? [
      Button.node(.init(handlers: [
        .touchUpInside: Handler { count.set { $0 + 1 } },
      ]), "Increment"),

      Label.node(.init(), "\(count.value)"),

      Slider.node(Slider.Props(
        value: sliding.value, valueHandler: Handler(sliding.set)
      )),

      Label.node(.init(), "\(sliding.value)"),
    ] : []

    return StackView.node(.init(axis: .vertical,
                                distribution: .fillEqually,
                                Style(.frame(.zero))),
                          children)
  }
}

final class GluonTests: XCTestCase {
  func testMount() {
    let renderer = TestRenderer(Counter.node(42))
    let root = renderer.rootTarget

    XCTAssertTrue(root.node.isSubtypeOf(View.self))
    XCTAssertEqual(root.subviews.count, 1)
    let stack = root.subviews[0]
    XCTAssertTrue(stack.node.isSubtypeOf(StackView.self))
    XCTAssertTrue(type(of: stack.node.props.value) == StackView.Props.self)
    XCTAssertEqual(stack.subviews.count, 4)
    XCTAssertTrue(stack.subviews[0].node.isSubtypeOf(Button.self))
    XCTAssertTrue(stack.subviews[1].node.isSubtypeOf(Label.self))
    XCTAssertEqual(stack.subviews[1].node.children, AnyEquatable("42"))
  }

  func testUpdate() {
    let renderer = TestRenderer(Counter.node(42))
    let root = renderer.rootTarget
    let stack = root.subviews[0]

    guard let buttonProps = stack.subviews[0].props(Button.Props.self),
      let buttonHandler = buttonProps.handlers[.touchUpInside]?.value else {
      XCTAssert(false, "components have no handlers")
      return
    }

    let originalLabel = stack.subviews[1]

    buttonHandler(())

    let e = expectation(description: "rerender")

    DispatchQueue.main.async {
      XCTAssertTrue(root.node.isSubtypeOf(View.self))
      XCTAssertEqual(root.subviews.count, 1)
      let newStack = root.subviews[0]
      XCTAssert(stack === newStack)
      XCTAssertTrue(newStack.node.isSubtypeOf(StackView.self))
      XCTAssertNotNil(newStack.props(StackView.Props.self))
      XCTAssertEqual(newStack.subviews.count, 4)
      XCTAssertTrue(newStack.subviews[0].node.isSubtypeOf(Button.self))
      XCTAssertTrue(newStack.subviews[1].node.isSubtypeOf(Label.self))
      XCTAssertTrue(originalLabel === newStack.subviews[1])
      XCTAssertEqual(newStack.subviews[1].node.children, AnyEquatable("43"))

      e.fulfill()
    }

    wait(for: [e], timeout: 30)
  }

  func testDoubleUpdate() {
    let renderer = TestRenderer(Counter.node(42))
    let root = renderer.rootTarget
    let stack = root.subviews[0]

    guard let buttonProps = stack.subviews[0].props(Button.Props.self),
      let sliderProps = stack.subviews[2].props(Slider.Props.self),
      let buttonHandler = buttonProps.handlers[.touchUpInside]?.value,
      let sliderHandler = sliderProps.valueHandler?.value else {
      XCTAssert(false, "components have no handlers")
      return
    }

    let originalLabel = stack.subviews[1]

    buttonHandler(())

    let e = expectation(description: "rerender")

    DispatchQueue.main.async {
      sliderHandler(0.25)

      DispatchQueue.main.async {
        XCTAssert(root.node.isSubtypeOf(View.self))
        XCTAssertEqual(root.subviews.count, 1)
        let newStack = root.subviews[0]
        XCTAssertTrue(stack === newStack)
        XCTAssertTrue(newStack.node.isSubtypeOf(StackView.self))
        XCTAssertNotNil(newStack.props(StackView.Props.self))
        XCTAssertEqual(newStack.subviews.count, 4)
        XCTAssertTrue(newStack.subviews[0].node.isSubtypeOf(Button.self))
        XCTAssertTrue(newStack.subviews[1].node.isSubtypeOf(Label.self))
        XCTAssertTrue(originalLabel === newStack.subviews[1])

        guard let sliderProps = newStack.subviews[2].props(Slider.Props.self),
          let buttonProps = newStack.subviews[0].props(Button.Props.self),
          let buttonHandler = buttonProps.handlers[.touchUpInside]?.value else {
          XCTAssert(false, "components have wrong props")
          return
        }

        XCTAssertEqual(sliderProps.value, 0.25)
        XCTAssertEqual(newStack.subviews[1].node.children, AnyEquatable("43"))

        buttonHandler(())

        DispatchQueue.main.async {
          XCTAssertTrue(root.node.isSubtypeOf(View.self))
          XCTAssertEqual(root.subviews.count, 1)
          let newStack = root.subviews[0]
          XCTAssertTrue(stack === newStack)
          XCTAssertTrue(newStack.node.isSubtypeOf(StackView.self))
          XCTAssertNotNil(newStack.props(StackView.Props.self))
          XCTAssertEqual(newStack.subviews.count, 4)
          XCTAssertTrue(newStack.subviews[0].node.isSubtypeOf(Button.self))
          XCTAssertTrue(newStack.subviews[1].node.isSubtypeOf(Label.self))
          XCTAssertTrue(originalLabel === newStack.subviews[1])

          XCTAssertEqual(sliderProps.value, 0.25)
          XCTAssertEqual(newStack.subviews[1].node.children, AnyEquatable("44"))
          e.fulfill()
        }
      }
    }

    wait(for: [e], timeout: 1)
  }

  func testUnmount() {
    let renderer = TestRenderer(Counter.node(42))
    let root = renderer.rootTarget

    let stack = root.subviews[0]
    guard let props = stack.subviews[0].props(Button.Props.self) else {
      XCTAssert(false, "button component has wrong props types")
      return
    }

    guard let handler = props.handlers[.touchUpInside]?.value else {
      XCTAssert(false, "button component has no handler")
      return
    }

    handler(())

    let e = expectation(description: "rerender")

    DispatchQueue.main.async {
      // rerender completed here, schedule another one
      guard let props = root.subviews[0].subviews[0].node
        .props.value as? Button.Props,
        let handler = props.handlers[.touchUpInside]?.value else {
        XCTAssert(false, "button component has no handler")
        return
      }

      handler(())

      DispatchQueue.main.async {
        guard let props = stack.subviews[0].props(Button.Props.self),
          let handler = props.handlers[.touchUpInside]?.value else {
          XCTAssert(false, "button component has no handler")
          return
        }

        handler(())

        DispatchQueue.main.async {
          XCTAssertTrue(root.node.isSubtypeOf(View.self))
          XCTAssertEqual(root.subviews.count, 1)
          let stack = root.subviews[0]
          XCTAssertTrue(stack.node.isSubtypeOf(StackView.self))
          XCTAssertTrue(type(of: stack.node.props.value) ==
            StackView.Props.self)
          XCTAssertEqual(stack.subviews.count, 0)

          e.fulfill()
        }
      }
    }

    wait(for: [e], timeout: 1)
  }

  static var allTests = [
    ("testMount", testMount),
  ]
}
