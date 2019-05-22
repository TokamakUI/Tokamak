//
//  Node.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 5/11/19.
//

import Foundation
import SwiftSyntax

final class Node: Equatable {
  static func ==(lhs: Node, rhs: Node) -> Bool {
    return lhs.text == rhs.text &&
      lhs.children == rhs.children &&
      lhs.parent == rhs.parent &&
      lhs.range == rhs.range
  }

  var text: String
  private(set) var children = [Node]()
  private(set) weak var parent: Node?
  var range = Range(startRow: 0, startColumn: 0, endRow: 0, endColumn: 0)

  struct Range: Equatable {
    var startRow: Int
    var startColumn: Int
    var endRow: Int
    var endColumn: Int
  }

  init(text: String) {
    self.text = text
  }

  func add(node: Node) {
    node.parent = self
    children.append(node)
  }

  func children(with type: String) -> [Node] {
    guard children.first != nil else { return [] }
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

  func firstParent(of type: SyntaxKind) -> Node? { return firstParent(of: type.rawValue) }

  func firstParent(of type: String) -> Node? {
    var nodeParent = self

    while nodeParent.text != type && nodeParent.parent != nil {
      guard let parent = nodeParent.parent else { break }
      nodeParent = parent
    }

    guard nodeParent.text == type else { return nil }

    return nodeParent
  }

  func firstChild(of type: SyntaxKind) -> Node? { return firstChild(of: type.rawValue) }

  func firstChild(of type: String) -> Node? {
    guard !children.isEmpty else { return nil }

    return children.first { $0.text == type } ??
      children.compactMap { $0.firstChild(of: type) }.first
  }

  func isInherited(from type: String) -> Bool {
    let typeNodes = children(
      with: SyntaxKind.simpleTypeIdentifier.rawValue
    )
    return typeNodes.flatMap { $0.children }.contains { $0.text == type }
  }
}
