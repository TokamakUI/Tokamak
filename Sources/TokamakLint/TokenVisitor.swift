//
//  TokenVisitor.swift
//  SwiftSyntax
//
//  Created by Matvii Hodovaniuk on 4/2/19.
//

// add code comments to methods

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
    if current == nil {
      tree.append(node)
    } else {
      current?.add(node: node)
    }
    current = node
  }

  override func visit(_ token: TokenSyntax) -> SyntaxVisitorContinueKind {
    current?.text = escapeHtmlSpecialCharacters(token.text)
    print(token.text)
    current?.token = Node.Token(
      kind: "\(token.tokenKind)",
      leadingTrivia: "",
      trailingTrivia: ""
    )

    current?.range.startRow = row
    current?.range.startColumn = column

    token.leadingTrivia.forEach { piece in
      let trivia = processTriviaPiece(piece)
      current?.token?.leadingTrivia += replaceSymbols(text: trivia)
    }
    processToken(token)
    token.trailingTrivia.forEach { piece in
      let trivia = processTriviaPiece(piece)
      current?.token?.trailingTrivia += replaceSymbols(text: trivia)
    }

    current?.range.endRow = row
    current?.range.endColumn = column

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

  private func processTriviaPiece(_ piece: TriviaPiece) -> String {
    var trivia = ""
    switch piece {
    case let .spaces(count):
      trivia += String(repeating: "&nbsp;", count: count)
      column += count
    case let .tabs(count):
      trivia += String(repeating: "&nbsp;", count: count * 2)
      column += count * 2
    case let .newlines(count),
         let .carriageReturns(count),
         let .carriageReturnLineFeeds(count):
      trivia += String(repeating: "<br>\n", count: count)
      row += count
      column = 0
    case let .backticks(count):
      trivia += String(repeating: "`", count: count)
      column += count
    default:
      break
    }
    return trivia
  }

  private func replaceSymbols(text: String) -> String {
    return text.replacingOccurrences(of: "&nbsp;", with: "␣")
      .replacingOccurrences(of: "<br>", with: "<br>↲")
  }

  private func escapeHtmlSpecialCharacters(_ string: String) -> String {
    var newString = string
    let specialCharacters = [
      "&": "&amp;",
      "<": "&lt;",
      ">": "&gt;",
      "\"": "&quot;",
      "'": "&apos;",
    ]
    for (escaped, unescaped) in specialCharacters {
      newString = newString.replacingOccurrences(
        of: escaped,
        with: unescaped,
        options: .literal,
        range: nil
      )
    }
    return newString
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
    var leadingTrivia: String
    var trailingTrivia: String
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
