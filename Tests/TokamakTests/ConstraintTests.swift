//
//  ConstraintsTests.swift
//  TokamakTests
//
//  Created by Matvii Hodovaniuk on 1/24/19.
//

import XCTest

@testable import Tokamak

final class ConstraintTests: XCTestCase {
  func testWidth() {
    let style = Style(Width.equal(to: .parent))
    XCTAssertEqual(
      style.layout,
      .constraints(
        [
          Constraint.width(
            Width(target: .external(.parent), constant: 0.0, multiplier: 1.0)
          ),
        ]
      )
    )
  }

  func testHeight() {
    let style = Style(Height.equal(to: .parent))
    XCTAssertEqual(
      style.layout,
      .constraints(
        [
          Constraint.height(
            Height(target: .external(.parent), constant: 0.0, multiplier: 1.0)
          ),
        ]
      )
    )
  }

  func testTop() {
    let style = Style(Top.equal(to: .parent))
    XCTAssertEqual(
      style.layout,
      .constraints(
        [
          Constraint.top(
            Top(target: .external(.parent), constant: 0.0)
          ),
        ]
      )
    )
  }

  func testBottom() {
    let style = Style(Bottom.equal(to: .parent))
    XCTAssertEqual(
      style.layout,
      .constraints(
        [
          Constraint.bottom(
            Bottom(target: .external(.parent), constant: 0.0)
          ),
        ]
      )
    )
  }

  func testLeft() {
    let style = Style(Left.equal(to: .parent))
    XCTAssertEqual(
      style.layout,
      .constraints(
        [
          Constraint.left(
            Left(target: .external(.parent), constant: 0.0)
          ),
        ]
      )
    )
  }

  func testRight() {
    let style = Style(Right.equal(to: .parent))
    XCTAssertEqual(
      style.layout,
      .constraints(
        [
          Constraint.right(
            Right(target: .external(.parent), constant: 0.0)
          ),
        ]
      )
    )
  }

  func testLeading() {
    let style = Style(Leading.equal(to: .parent))
    XCTAssertEqual(
      style.layout,
      .constraints(
        [
          Constraint.leading(
            Leading(target: .external(.parent), constant: 0.0)
          ),
        ]
      )
    )
  }

  func testTrailing() {
    let style = Style(Right.equal(to: .parent))
    XCTAssertEqual(
      style.layout,
      .constraints(
        [
          Constraint.right(
            Right(target: .external(.parent), constant: 0.0)
          ),
        ]
      )
    )
  }
}
