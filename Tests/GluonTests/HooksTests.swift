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

    return View.node([
      Button.node(.init(onPress: Handler { state1.set { $0 + 1 } }),
                  "Increment"),
      Label.node("\(state1.value)"),
      Button.node(.init(onPress: Handler { state2.set { $0 + 1 } }),
                  "Increment"),
      Label.node("\(state2.value)"),
    ])
  }
}
