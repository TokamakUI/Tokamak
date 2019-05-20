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
    let oneRenderFunctionRuleresult = try OneRenderFunctionRule.validate(path: path)
    XCTAssertEqual(oneRenderFunctionRuleresult.count, 2)
    XCTAssertEqual(oneRenderFunctionRuleresult[0].location.line, 41)
    XCTAssertEqual(oneRenderFunctionRuleresult[1].location.line, 60)
  }

  func testTwoComponentsBrokenBroken() throws {
    let path = "\(try srcRoot())/TwoComponentsBrokenBroken.swift"
    let oneRenderFunctionRuleresult = try OneRenderFunctionRule.validate(path: path)
    XCTAssertEqual(oneRenderFunctionRuleresult.count, 4)
    XCTAssertEqual(oneRenderFunctionRuleresult[0].location.line, 10)
    XCTAssertEqual(oneRenderFunctionRuleresult[1].location.line, 29)
    XCTAssertEqual(oneRenderFunctionRuleresult[2].location.line, 60)
    XCTAssertEqual(oneRenderFunctionRuleresult[3].location.line, 79)
  }
}
