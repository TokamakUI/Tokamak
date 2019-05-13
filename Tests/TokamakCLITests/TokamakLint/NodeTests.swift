//
//  NodeTests.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 5/11/19.
//

import SwiftSyntax
@testable import TokamakLint
import XCTest

final class NodeTests: XCTestCase {
  func testCollectChildren() throws {
    let houseLannister = Node(text: "Tywin")

    houseLannister.add(node: Node(text: "Jaime"))
    houseLannister.add(node: Node(text: "Cersei"))
    houseLannister.add(node: Node(text: "Tyrion"))

    XCTAssertEqual(houseLannister.children(with: "Jaime").count, 1)
    XCTAssertEqual(houseLannister.children(with: "JonSnow").count, 0)

    let cerseiChildren = Node(text: "Cersei")

    let joffrey = Node(text: "Joffrey")
    joffrey.add(node: Node(text: "Father: Jaime"))
    cerseiChildren.add(node: joffrey)

    let myrcella = Node(text: "Myrcella")
    myrcella.add(node: Node(text: "Father: Jaime"))
    cerseiChildren.add(node: myrcella)

    let tommen = Node(text: "Tommen")
    tommen.add(node: Node(text: "Father: Jaime"))
    cerseiChildren.add(node: tommen)

    XCTAssertEqual(cerseiChildren.children(with: "Father: Jaime").count, 3)
    XCTAssertEqual(cerseiChildren.children(with: "Father: Robert").count, 0)
  }

  func testFirstParent() throws {
    let houseTargaryen = Node(text: "House Targryen")

    let aerys = Node(text: "Aerys \"the Mad\"")
    houseTargaryen.add(node: aerys)

    let rhaegar = Node(text: "Rhaegar")
    aerys.add(node: rhaegar)

    let jonSnow = Node(text: "Jon Snow")
    rhaegar.add(node: jonSnow)

    guard let madKing = jonSnow.firstParent(of: "Aerys \"the Mad\"") else {
      throw UnexpectedNilError()
    }
    XCTAssertEqual(madKing.text, "Aerys \"the Mad\"")
  }

  func testFirstChild() throws {
    let path = "\(try srcRoot())/NodeStruct.swift"
    let fileURL = URL(fileURLWithPath: path)
    let parsedTree = try SyntaxTreeParser.parse(fileURL)
    let visitor = TokenVisitor(path: path)
    parsedTree.walk(visitor)

    guard let firstStruct = visitor.root.firstChild(
      of: SyntaxKind.structDecl.rawValue
    )
    else { throw UnexpectedNilError() }

    XCTAssertEqual(firstStruct.children[1].text, "Img")
  }
}
