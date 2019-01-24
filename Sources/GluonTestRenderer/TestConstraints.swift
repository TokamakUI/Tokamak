//
//  ConstraintsTests.swift
//  Gluon
//
//  Created by Matvii Hodovaniuk on 1/24/19.
//

@testable import Gluon
import XCTest

public final class TestConstraints {
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
