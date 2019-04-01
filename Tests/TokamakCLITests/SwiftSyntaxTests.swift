//
//  SwiftSyntaxTests.swift
//  TokamakCLI
//
//  Created by Matvii Hodovaniuk on 3/31/19.
//

/// Users/hmi/Documents/maxDesiatov/Tokamak/.build/debug/TokamakCLI "/Users/hmi/Documents/maxDesiatov/Tokamak/Sources/TokamakCLI/main.swift"

import TokamakCLI
import XCTest

final class SwiftSyntaxTests: XCTestCase {
  func testAllFiles() {
    let linter = CommandLineTool()
    print(linter.self)
//        let a = try linter.run()
//        print(a == "")
  }
}
