//
//  ConstraintsTests.swift
//  Gluon
//
//  Created by Matvii Hodovaniuk on 1/24/19.
//

import XCTest

@testable import Gluon

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
}
