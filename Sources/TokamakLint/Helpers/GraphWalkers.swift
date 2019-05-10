//
//  GraphWalkers.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 5/9/19.
//

import Foundation
import SwiftSyntax

enum GraphWalkersError: Error {
  case noParent
  case noChild
}

func parent(of type: String, in node: Node) -> Node? {
  var nodeParent = node

  while nodeParent.text != SyntaxKind.codeBlockItem.rawValue && nodeParent.parent != nil {
    guard let parent = nodeParent.parent else { break }
    nodeParent = parent
  }

  guard nodeParent.text == type else { return nil }

  return nodeParent
}

func firstChild(of type: String, in node: Node) -> Node? {
  guard !node.children.isEmpty else { return nil }

  return node.children.first { $0.text == type } ??
    node.children.compactMap { firstChild(of: type, in: $0) }.first
}
