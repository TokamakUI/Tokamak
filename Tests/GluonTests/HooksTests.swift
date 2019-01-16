//
//  HooksTests.swift
//  GluonTests
//
//  Created by Max Desiatov on 16/01/2019.
//

import GluonTestRenderer
import XCTest

@testable import Gluon

private extension Hooks {
  func custom() -> State<Int> {
    return state(42)
  }
}

struct Test: LeafComponent {
  typealias Props = Null

  static func render(props: Null, hooks: Hooks) -> AnyNode {
    let state1 = hooks.custom()
    let state2 = hooks.custom()

    return StackView.node([
      Button.node(.init(onPress: Handler { state1.set { $0 + 1 } }),
                  "Increment"),
      Label.node("\(state1.value)"),
      Button.node(.init(onPress: Handler { state2.set { $0 + 1 } }),
                  "Increment"),
      Label.node("\(state2.value)"),
    ])
  }
}

final class HooksTests: XCTestCase {
  func testCustomHook() {
    let renderer = TestRenderer(Test.node(Null()))
    let root = renderer.rootTarget

    let stack = root.subviews[0]

    guard let buttonProps = stack.subviews[0].props(Button.Props.self),
      let buttonHandler = buttonProps.handlers[.touchUpInside]?.value else {
      XCTAssert(false, "components have no handlers")
      return
    }

    buttonHandler(())

    let e = expectation(description: "rerender")

    DispatchQueue.main.async {
      XCTAssertEqual(stack.subviews[1].node.children, AnyEquatable("43"))

      XCTAssertEqual(stack.subviews[3].node.children, AnyEquatable("42"))

      e.fulfill()
    }

    wait(for: [e], timeout: 30)
  }
}
