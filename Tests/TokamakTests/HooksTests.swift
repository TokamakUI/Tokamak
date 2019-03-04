//
//  HooksTests.swift
//  TokamakTests
//
//  Created by Max Desiatov on 16/01/2019.
//

import TokamakTestRenderer
import XCTest

@testable import Tokamak

struct Game {
  enum State {
    case initial
    case gameOver
    case isPlaying
  }

  var state = State.initial

  enum Direction {
    case up
    case down
    case left
    case right
  }

  var currentDirection = Direction.up

  var points = [Point]()

  var target = Point(x: 42, y: 42)

  let mapSize = Size(width: 42, height: 42)
}

extension Button: RefComponent {
  public typealias RefTarget = TestView
}

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
    let state3 = hooks.state(Game())
    let ref = hooks.ref(type: TestView.self)

    return StackView.node([
      Button.node(
        .init(onPress: Handler { state1.set { $0 += 1 } }),
        "Increment",
        ref: ref
      ),
      Label.node("\(state1.value)"),
      Button.node(.init(onPress: Handler { state2.set { $0 + 1 } }),
                  "Increment"),
      Label.node("\(state2.value)"),
      Button.node(
        .init(
          onPress: Handler {
            state3.set { $0.points.append(Point(x: 42, y: 42)) }
          }
        ),
        "Increment"
      ),
    ])
  }
}

final class HooksTests: XCTestCase {
  func testCustomHook() {
    let renderer = TestRenderer(Test.node(Null()))
    let root = renderer.rootTarget

    let stack = root.subviews[0]

    guard
      let button1Props = stack.subviews[0].props(Button.Props.self),
      let button1Handler = button1Props.handlers[.touchUpInside]?.value,
      let button2Props = stack.subviews[2].props(Button.Props.self),
      let button2Handler = button2Props.handlers[.touchUpInside]?.value,
      let button3Props = stack.subviews[4].props(Button.Props.self),
      let button3Handler = button3Props.handlers[.touchUpInside]?.value,
      let button1Ref = stack.subviews[0].node.ref as? Ref<TestView?>
    else {
      XCTAssert(false, "components have no handlers")
      return
    }

    XCTAssertTrue(button1Ref.value === stack.subviews[0])

    button1Handler(())

    button2Handler(())
    button2Handler(())

    button3Handler(())

    let e = expectation(description: "rerender")

    DispatchQueue.main.async {
      XCTAssertEqual(stack.subviews[1].node.children, AnyEquatable("43"))
      XCTAssertEqual(stack.subviews[3].node.children, AnyEquatable("44"))

      e.fulfill()
    }

    wait(for: [e], timeout: 30)
  }
}
