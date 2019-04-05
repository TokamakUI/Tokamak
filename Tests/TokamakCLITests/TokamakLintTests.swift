//
//  SwiftSyntaxTests.swift
//  TokamakCLI
//
//  Created by Matvii Hodovaniuk on 3/31/19.
//

import TokamakLint
import XCTest

let srcRoot = ProcessInfo.processInfo.environment["SRCROOT"]!

final class SwiftSyntaxTests: XCTestCase {
  func testAllFiles() throws {
    let linter = TokamakLint()
    let path = "\(srcRoot)/"
    try linter.lintFolder(path)
  }

  func testFile() throws {
    let linter = TokamakLint()
    let path = "\(srcRoot)/Sources/Tokamak/Components/Host/Alert.swift"
    try linter.lintFile(path)
  }

  func testPropsIsEquatable() throws {
    let linter = TokamakLint()
    let path = "\(srcRoot)/Tests/TokamakCLITests/TestPropsEquatable.swift"
    XCTAssertTrue(try linter.isPropsEquatable(path))
  }
}
