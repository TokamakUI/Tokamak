//
//  SwiftSyntaxTests.swift
//  TokamakCLI
//
//  Created by Matvii Hodovaniuk on 3/31/19.
//


import TokamakLint
import XCTest

let rightStruct = """
    struct Props: Equatable {
        str: String
    }
"""

let wrongStruct = """
    struct Props {
        str: String
    }
"""

final class SwiftSyntaxTests: XCTestCase {
  func testAllFiles() {
    let linter = TokamakLint()
    let path = "/Users/hmi/Documents/maxDesiatov/Tokamak/"
    linter.lintFolder(path)
  }

  func testFile() {
    let linter = TokamakLint()
//    let path = "/Users/hmi/Documents/maxDesiatov/Tokamak/Sources/Tokamak/Components/Host/Alert.swift"
    let path = "/Users/hmi/Documents/maxDesiatov/Tokamak/Tests/TokamakCLITests/TestProps.swift"
    linter.lintFile(path)

    // todo
    // use files to check props
  }
}
