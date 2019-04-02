//
//  TokenVisitor.swift
//  SwiftSyntax
//
//  Created by Matvii Hodovaniuk on 4/2/19.
//

import Foundation
import SwiftSyntax

class TokenVisitor: SyntaxVisitor {
  public var list = [String]()
  public var tree = [Node]()
  public var current: Node!

  var row = 0
  var column = 0

  override func visitPre(_ node: Syntax) {
    print(node)
    var syntax = "\(type(of: node))"
    if syntax.hasSuffix("Syntax") {
      syntax = String(syntax.dropLast(6))
    }
    list.append("<span class='\(syntax)' data-toggle='tooltip' title='\(syntax)'>")

    let node = Node(text: syntax)
    node.range.startRow = row
    node.range.startColumn = column
    node.range.endRow = row
    node.range.endColumn = column
    if current == nil {
      tree.append(node)
    } else {
      current.add(node: node)
    }
    current = node
  }

  override func visit(_ token: TokenSyntax) -> SyntaxVisitorContinueKind {
    print(token)
    current.text = escapeHtmlSpecialCharacters(token.text)
    current.token = Node.Token(kind: "\(token.tokenKind)", leadingTrivia: "", trailingTrivia: "")

    current.range.startRow = row
    current.range.startColumn = column

    token.leadingTrivia.forEach { piece in
      let trivia = processTriviaPiece(piece)
      list.append(trivia)
      current.token?.leadingTrivia += replaceSymbols(text: trivia)
    }
    processToken(token)
    token.trailingTrivia.forEach { piece in
      let trivia = processTriviaPiece(piece)
      list.append(trivia)
      current.token?.trailingTrivia += replaceSymbols(text: trivia)
    }

    current.range.endRow = row
    current.range.endColumn = column

    return .visitChildren
  }

  override func visitPost(_ node: Syntax) {
//    print(node)
//    list.append("</span>")
    current.range.endRow = row
    current.range.endColumn = column
    current = current.parent
  }

  private func processToken(_ token: TokenSyntax) {
    var kind = "\(token.tokenKind)"
    if let index = kind.firstIndex(of: "(") {
      kind = String(kind.prefix(upTo: index))
    }
    if kind.hasSuffix("Keyword") {
      kind = "keyword"
    }

    list.append("<span class='token \(kind)' data-toggle='tooltip' title='\(token.tokenKind)'>" + escapeHtmlSpecialCharacters(token.text) + "</span>")
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
    case let .newlines(count), let .carriageReturns(count), let .carriageReturnLineFeeds(count):
      trivia += String(repeating: "<br>\n", count: count)
      row += count
      column = 0
    case let .backticks(count):
      trivia += String(repeating: "`", count: count)
      column += count
    case let .lineComment(text):
      trivia += withSpanTag(class: "lineComment", text: text)
      processComment(text: text)
    case let .blockComment(text):
      trivia += withSpanTag(class: "blockComment", text: text)
      processComment(text: text)
    case let .docLineComment(text):
      trivia += withSpanTag(class: "docLineComment", text: text)
      processComment(text: text)
    case let .docBlockComment(text):
      trivia += withSpanTag(class: "docBlockComment", text: text)
      processComment(text: text)
    default:
      break
    }
    return trivia
  }

  private func withSpanTag(class c: String, text: String) -> String {
    return "<span class='\(c)'>" + escapeHtmlSpecialCharacters(text) + "</span>"
  }

  private func replaceSymbols(text: String) -> String {
    return text.replacingOccurrences(of: "&nbsp;", with: "␣").replacingOccurrences(of: "<br>", with: "<br>↲")
  }

  private func processComment(text: String) {
    let comments = text.split(separator: "\n", omittingEmptySubsequences: false)
    row += comments.count - 1
    column += comments.last!.count
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
      newString = newString.replacingOccurrences(of: escaped, with: unescaped, options: .literal, range: nil)
    }
    return newString
  }

    func isHasType(check node: Node,for type: String) -> Bool {
        if node.children.count > 0 {
            for child in node.children {
                isHasType(check: child, for: type)
            }
        }
        return node.text == type
    }

    func isInherited(node: Node, from type: String) -> Bool {
        let types = node.children.reduce("", { $0 == "" ? $1 : $0 + "," + $1 })
        print(types)
    }
}

class Node: Encodable {
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

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(text, forKey: .text)
    try container.encode(children, forKey: .children)
    try container.encode(range, forKey: .range)
    try container.encode(token, forKey: .token)
  }


}
