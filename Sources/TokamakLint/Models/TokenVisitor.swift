//
//  TokenVisitor.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 4/2/19.
//

import Foundation
import SwiftSyntax

class TokenVisitor: SyntaxVisitor {
  // Syntax tree is always have one 'SourceFile' node as a child
  public var root = Node(text: "Root")
  public var path: String?
  public var current: Node?

  var row = 0
  var column = 0

  public override func visitPre(_ node: Syntax) {
    var syntax = "\(type(of: node))"

    if syntax.hasSuffix("Syntax") {
      syntax = String(syntax.dropLast(6))
    }

    let syntaxNode = Node(text: syntax)

    if let current = current {
      current.add(node: syntaxNode)
    } else {
      root.children.append(syntaxNode)
    }
    current = syntaxNode
  }

  public override func visit(_ token: TokenSyntax) -> SyntaxVisitorContinueKind {
    guard let current = current else { return .visitChildren }

    current.text = token.text

    // set initial row and column to
    row = token.position.line
    column = token.position.column

    // process trivia pieces before token
    token.leadingTrivia.forEach { piece in
      processTriviaPiece(piece)
    }

    // set start of token
    current.range.startRow = row
    current.range.startColumn = column

    processToken(token)

    // process trivia pieces after token
    token.trailingTrivia.forEach { piece in
      processTriviaPiece(piece)
    }

    // set end of token
    current.range.endRow = row
    current.range.endColumn = column

    return .visitChildren
  }

  public override func visitPost(_ node: Syntax) {
    // go up after full node walk
    current = current?.parent
  }

  private func processToken(_ token: TokenSyntax) {
    column += token.text.count
  }

  private func processTriviaPiece(_ piece: TriviaPiece) {
    switch piece {
    case let .spaces(count):
      column += count
    case let .tabs(count):
      column += count * 2
    case let .newlines(count), let .carriageReturns(count), let .carriageReturnLineFeeds(count):
      row += count
      column = 0
    case let .backticks(count):
      column += count
    case let .lineComment(text):
      processComment(text: text)
    case let .blockComment(text):
      processComment(text: text)
    case let .docLineComment(text):
      processComment(text: text)
    case let .docBlockComment(text):
      processComment(text: text)
    default:
      break
    }
  }

  private func processComment(text: String) {
    let comments = text.split(separator: "\n", omittingEmptySubsequences: false)
    guard let last = comments.last else { return }
    // substract 1 to prevent double newline count in comment and new line
    row += comments.count - 1
    column += last.count
  }
}

public class Node {
  var text: String
  var children = [Node]()
  weak var parent: Node?
  var range = Range(startRow: 0, startColumn: 0, endRow: 0, endColumn: 0)

  struct Range {
    var startRow: Int
    var startColumn: Int
    var endRow: Int
    var endColumn: Int
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

  func getNodes(with type: String) -> [Node] {
    guard let first = self.children.first else { return [] }
    var nodes: [Node] = []
    walkAndGrab(get: type, from: self, to: &nodes)
    return nodes
  }

  func walkAndGrab(
    get type: String,
    from node: Node,
    to list: inout [Node]
  ) {
    if node.text == type {
      list.append(node)
    }
    for child in node.children {
      walkAndGrab(get: type, from: child, to: &list)
    }
  }
}

func isInherited(node: Node, from type: String) -> Bool {
  var str: String = ""
  let typeNodes = node.getNodes(with: "SimpleTypeIdentifier")
  for node in typeNodes {
    for type in node.children {
      str.append("\(type.text)")
    }
  }
  return str.contains(type)
}
