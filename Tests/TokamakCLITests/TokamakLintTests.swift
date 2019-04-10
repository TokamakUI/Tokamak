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
    let path = "\(srcRoot)/"
    try lintFolder(path)
  }

  func testFile() throws {
    let path = "\(srcRoot)/Sources/Tokamak/Components/Host/Alert.swift"
    let result = try lintFile(path)
    XCTAssertEqual(result, [])
  }

  func testPropsIsEquatable() throws {
    let path = "\(srcRoot)/ValidationTests/TestPropsEquatable.swift"
    XCTAssertTrue(try isPropsEquatable(path))
  }

  func testPropsIsNotEquatable() throws {
    let path = "\(srcRoot)/ValidationTests/TestPropsIsNotEquatable.swift"
    XCTAssertFalse(try isPropsEquatable(path))
  }
}
