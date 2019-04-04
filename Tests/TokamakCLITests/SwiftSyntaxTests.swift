//
//  SwiftSyntaxTests.swift
//  TokamakCLI
//
//  Created by Matvii Hodovaniuk on 3/31/19.
//

import TokamakLint
import XCTest

final class SwiftSyntaxTests: XCTestCase {
  func testAllFiles() throws {
    let linter = TokamakLint()
    let path = "/Users/hmi/Documents/maxDesiatov/Tokamak/"
    try linter.lintFolder(path)
  }

  func testFile() throws {
    let linter = TokamakLint()
    let path = "/Users/hmi/Documents/maxDesiatov/Tokamak/Sources/Tokamak/Components/Host/Alert.swift"
    try linter.lintFile(path)
  }

  func testPropsIsEquatable() throws {
    let linter = TokamakLint()
    let path = "/Users/hmi/Documents/maxDesiatov/Tokamak/Tests/TokamakCLITests/TestPropsEquatable.swift"
    XCTAssertTrue(try linter.isPropsEquatable(path))
  }
}
