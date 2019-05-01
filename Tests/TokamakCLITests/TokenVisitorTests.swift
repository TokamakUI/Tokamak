//
//  TokenVisitorTests.swift
//  SwiftSyntax
//
//  Created by Matvii Hodovaniuk on 5/1/19.
//

@testable import TokamakLint
import XCTest
import SwiftSyntax

final class TokenVisitorTests: XCTestCase {
  func testRange() throws {
    let srcRoot = ProcessInfo.processInfo.environment["SRCROOT"]!
    let path = "\(srcRoot)/ValidationTests/TestPropsEquatable.swift"

    let fileURL = URL(fileURLWithPath: path)
    let parsedTree = try SyntaxTreeParser.parse(fileURL)
    let visitor = TokenVisitor()

    visitor.path = path
    parsedTree.walk(visitor)

    let startRow = 9
    let endRow = 16
    let startColumn = 15
    let endColumn = 1
    let structs = visitor.getNodes(get: "StructDecl", from: visitor.tree[0])

    XCTAssertEqual(startRow, structs[0].range.startRow)
    XCTAssertEqual(endRow, structs[0].range.endRow)
    XCTAssertEqual(startColumn, structs[0].range.startColumn)
    XCTAssertEqual(endColumn, structs[0].range.endColumn)
  }
}
