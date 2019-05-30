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

  func testOneRenderFunctionRulePositive() throws {
    let path = "\(try srcRoot())/OneRenderFunctionPositive.swift"
    let result = try OneRenderFunctionRule.validate(path: path)
    XCTAssertEqual(result, [])
  }

  func testOneRenderFunctionRuleNegative() throws {
    let path = "\(try srcRoot())/OneRenderFunctionNegative.swift"
    let result = try OneRenderFunctionRule.validate(path: path)
    XCTAssertEqual(result.count, 6)
  }

  func testRenderGetsHooksRulePositive() throws {
    let path = "\(try srcRoot())/RenderGetsHooksRulePositive.swift"
    let result = try RenderGetsHooksRule.validate(path: path)
    XCTAssertEqual(result, [])
  }

  func testRenderGetsHooksRuleNegative() throws {
    let path = "\(try srcRoot())/RenderGetsHooksRuleNegative.swift"
    let result = try RenderGetsHooksRule.validate(path: path)
    XCTAssertEqual(result.count, 3)
  }

  func testTwoComponentsCorrectBroken() throws {
    let path = "\(try srcRoot())/TwoComponentsCorrectBroken.swift"
    let result = try OneRenderFunctionRule.validate(path: path)
    XCTAssertEqual(result.count, 2)
    XCTAssertEqual(result[0].location.line, 41)
    XCTAssertEqual(result[1].location.line, 60)
  }

  func testTwoComponentsBrokenBroken() throws {
    let path = "\(try srcRoot())/TwoComponentsBrokenBroken.swift"
    let result = try OneRenderFunctionRule.validate(path: path)
    XCTAssertEqual(result.count, 4)
    XCTAssertEqual(result[0].location.line, 10)
    XCTAssertEqual(result[1].location.line, 29)
    XCTAssertEqual(result[2].location.line, 60)
    XCTAssertEqual(result[3].location.line, 79)
  }

  func testTwoComponentsCorrectCorrect() throws {
    let path = "\(try srcRoot())/TwoComponentsCorrectCorrect.swift"
    let result = try OneRenderFunctionRule.validate(path: path)
    XCTAssertEqual(result.count, 0)
  }

  func testHooksRulePositive() throws {
    let path = "\(try srcRoot())/HooksRulePositive.swift"
    let result = try HooksRule.validate(path: path)
    XCTAssertEqual(result.count, 0)
  }

  func testHooksRuleNegative() throws {
    let path = "\(try srcRoot())/HooksRuleNegative.swift"
    let result = try HooksRule.validate(path: path)
    XCTAssertEqual(result.count, 12)
    let violationsLines = [
      7, 15, 20, 40, 45, 53, 79, 81, 29, 31, 69, 71,
    ]
    for (i, line) in violationsLines.enumerated() {
      XCTAssertEqual(result[i].location.line, line)
    }
  }

  func testComponentIsStructRulePositive() throws {
    let path = "\(try srcRoot())/ComponentAsStructPositive.swift"
    let result = try ComponentIsStructRule.validate(path: path)
    XCTAssertEqual(result.count, 0)
  }

  func testComponentIsStructRuleNegative() throws {
    let path = "\(try srcRoot())/ComponentAsStructNegative.swift"
    let result = try ComponentIsStructRule.validate(path: path)
    XCTAssertEqual(result.count, 2)
  }
}
