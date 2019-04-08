//
//  TokenVisitor.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 4/2/19.
//

import Foundation
import SwiftSyntax

class TokenVisitor: SyntaxVisitor {
  public var tree = [Node]()
  public var current: Node?

  var row = 0
  var column = 0

  override func visitPre(_ node: Syntax) {
    var syntax = "\(type(of: node))"
    if syntax.hasSuffix("Syntax") {
      syntax = String(syntax.dropLast(6))
    }

    let node = Node(text: syntax)
    node.range.startRow = row
    node.range.startColumn = column
    node.range.endRow = row
    node.range.endColumn = column
    if let current = current {
      current.add(node: node)
    } else {
      tree.append(node)
    }
    current = node
  }

  override func visit(_ token: TokenSyntax) -> SyntaxVisitorContinueKind {
    guard let current = current else { return .visitChildren }
    current.text = token.text
    current.token = Node.Token(
      kind: "\(token.tokenKind)"
    )

    current.range.startRow = row
    current.range.startColumn = column

    processToken(token)

    current.range.endRow = row
    current.range.endColumn = column

    return .visitChildren
  }

  override func visitPost(_ node: Syntax) {
    current?.range.endRow = row
    current?.range.endColumn = column
    current = current?.parent
  }

  private func processToken(_ token: TokenSyntax) {
    var kind = "\(token.tokenKind)"
    if let index = kind.firstIndex(of: "(") {
      kind = String(kind.prefix(upTo: index))
    }
    if kind.hasSuffix("Keyword") {
      kind = "keyword"
    }

    column += token.text.count
  }

  public func getNodes(get type: String, from node: Node) -> [Node] {
    var nodes: [Node] = []
    walkAndGrab(get: type, from: node, to: &nodes)
    return nodes
  }

  public func walkAndGrab(
    get type: String,
    from node: Node,
    to list: inout [Node]
  ) {
    if node.text == type {
      list.append(node)
    }
    if node.children.count > 0 {
      for child in node.children {
        walkAndGrab(get: type, from: child, to: &list)
      }
    }
  }

  func isInherited(node: Node, from type: String) -> Bool {
    var str: String = ""
    let typeNodes = getNodes(get: "SimpleTypeIdentifier", from: node)
    for node in typeNodes {
      for type in node.children {
        str.append("\(type.text)")
      }
    }
    return str.contains(type)
  }
}

class Node {
  var text: String
  var children = [Node]()
  weak var parent: Node?
  var range = Range(startRow: 0, startColumn: 0, endRow: 0, endColumn: 0)
  var token: Token?

  struct Range: Encodable {
    var startRow: Int
    var startColumn: Int
    var endRow: Int
    var endColumn: Int
  }

  struct Token: Encodable {
    var kind: String
  }

  enum CodingKeys: CodingKey {
    case text
    case children
    case range
    case token
  }

  init(text: String) {
    self.text = text
  }

  func add(node: Node) {
    node.parent = self
    children.append(node)
  }
}
