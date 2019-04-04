//
//  SwiftSyntaxTests.swift
//  TokamakCLI
//
//  Created by Matvii Hodovaniuk on 3/31/19.
//

import TokamakLint
import XCTest

final class SwiftSyntaxTests: XCTestCase {
  func testAllFiles() {
    let linter = TokamakLint()
    let path = "/Users/hmi/Documents/maxDesiatov/Tokamak/"
    linter.lintFolder(path)
  }

  func testFile() {
    let linter = TokamakLint()
    let path = "/Users/hmi/Documents/maxDesiatov/Tokamak/Sources/Tokamak/Components/Host/Alert.swift"
    linter.lintFile(path)
  }

  func testPropsIsEquatable() {
    let linter = TokamakLint()
    let path = "/Users/hmi/Documents/maxDesiatov/Tokamak/Tests/TokamakCLITests/TestPropsEquatable.swift"
    XCTAssertTrue(linter.isPropsEquatable(path))
  }
}
