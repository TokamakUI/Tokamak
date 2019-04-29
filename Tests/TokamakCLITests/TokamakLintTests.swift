//
//  SwiftSyntaxTests.swift
//  TokamakCLI
//
//  Created by Matvii Hodovaniuk on 3/31/19.
//

@testable import TokamakLint
import XCTest

let srcRoot = ProcessInfo.processInfo.environment["SRCROOT"]!

final class SwiftSyntaxTests: XCTestCase {
  func testFile() throws {
    let path = "\(srcRoot)/Sources/Tokamak/Components/Host/Alert.swift"
    let result = try lintFile(path)
    XCTAssertEqual(result, [])
  }

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
}
