//
//  TokamakLintTests.swift
//  TokamakCLI
//
//  Created by Matvii Hodovaniuk on 3/31/19.
//

@testable import TokamakLint
import XCTest

let srcRoot = ProcessInfo.processInfo.environment["SRCROOT"]!

final class TokamakLintTests: XCTestCase {
  func testPositivePropsIsEquatableRule() throws {
    let path = "\(srcRoot)/ValidationTests/TestPropsEquatable.swift"
    let result = try PropsIsEquatableRule.validate(path: path)
    XCTAssertEqual(result, [])
  }

  func testNegativePropsIsEquatableRule() throws {
    let path = "\(srcRoot)/ValidationTests/TestPropsIsNotEquatable.swift"
    let result = try PropsIsEquatableRule.validate(path: path)
    XCTAssertEqual(result.count, 1)
  }

  func testOneRenderFunctionRule() throws {
    let path = "\(srcRoot)/ValidationTests/PositiveTestHooksRule.swift"
    let result = try OneRenderFunctionRule.validate(path: path)
    XCTAssertEqual(result, [])
  }

  func testRenderCorespondToNonPureComponentProtocolRule() throws {
    let path = "\(srcRoot)/ValidationTests/PositiveTestHooksRule.swift"
    let result = try RenderCorespondToNonPureComponentProtocolRule.validate(path: path)
    XCTAssertEqual(result, [])
  }
}
