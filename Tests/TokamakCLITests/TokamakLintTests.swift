//
//  TokamakLintTests.swift
//  TokamakCLI
//
//  Created by Matvii Hodovaniuk on 3/31/19.
//

@testable import TokamakLint
import XCTest

final class TokamakLintTests: XCTestCase {
  func testPositivePropsIsEquatableRule() throws {
    let path = "\(try srcRoot())/TestPropsEquatable.swift"
    let result = try PropsIsEquatableRule.validate(path: path)
    XCTAssertEqual(result, [])
  }

  func testNegativePropsIsEquatableRule() throws {
    let path = "\(try srcRoot())/TestPropsIsNotEquatable.swift"
    let result = try PropsIsEquatableRule.validate(path: path)
    XCTAssertEqual(result.count, 1)
  }

  func testOneRenderFunctionRule() throws {
    let path = "\(try srcRoot())/PositiveTestHooksRule.swift"
    let result = try OneRenderFunctionRule.validate(path: path)
    XCTAssertEqual(result, [])
  }

  func testNegativeTestHooksRule() throws {
    let path = "\(try srcRoot())/NegativeTestHooksRule.swift"
    let result = try OneRenderFunctionRule.validate(path: path)
    XCTAssertEqual(result, [])
  }

  func testRenderGetsHooksRule() throws {
    let path = "\(try srcRoot())/PositiveTestHooksRule.swift"
    let result = try RenderGetsHooksRule.validate(path: path)
    XCTAssertEqual(result, [])
  }

  func testTwoComponentsCorrectBroken() throws {
    let path = "\(try srcRoot())/TwoComponentsCorrectBroken.swift"
    let oneRenderFunctionRuleResult = try OneRenderFunctionRule.validate(path: path)
    XCTAssertEqual(oneRenderFunctionRuleResult.count, 2)
    XCTAssertEqual(oneRenderFunctionRuleResult[0].location.line, 41)
    XCTAssertEqual(oneRenderFunctionRuleResult[1].location.line, 60)
  }

  func testTwoComponentsBrokenBroken() throws {
    let path = "\(try srcRoot())/TwoComponentsBrokenBroken.swift"
    let oneRenderFunctionRuleResult = try OneRenderFunctionRule.validate(path: path)
    XCTAssertEqual(oneRenderFunctionRuleResult.count, 4)
    XCTAssertEqual(oneRenderFunctionRuleResult[0].location.line, 10)
    XCTAssertEqual(oneRenderFunctionRuleResult[1].location.line, 29)
    XCTAssertEqual(oneRenderFunctionRuleResult[2].location.line, 60)
    XCTAssertEqual(oneRenderFunctionRuleResult[3].location.line, 79)
  }

  func testTwoComponentsCorrectCorrect() throws {
    let path = "\(try srcRoot())/TwoComponentsCorrectCorrect.swift"
    let oneRenderFunctionRuleResult = try OneRenderFunctionRule.validate(path: path)
    XCTAssertEqual(oneRenderFunctionRuleResult.count, 0)
  }
}
