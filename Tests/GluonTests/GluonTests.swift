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

    let handler = Handler {
      setCount(count + 1)
    }

    return StackView.node(.init(axis: .vertical,
                                distribution: .fillEqually,
                                frame: .zero), [
        Button.node(.init(handlers: [.touchUpInside: handler]), "Increment"),
        Label.node(Null(), "\(count)"),
    ])
  }
}

final class GluonTests: XCTestCase {
  func testMount() {
    let renderer = TestRenderer(Counter.node(42))
  }

  func testUpdate() {}

  func testUnmount() {}

  static var allTests = [
    ("testMount", testMount),
  ]
}
