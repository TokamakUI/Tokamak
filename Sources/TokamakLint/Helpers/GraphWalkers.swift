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

func getParentOf(type: String, in node: Node) throws -> Node {
  var nodeParent = node

  while nodeParent.text != SyntaxKind.codeBlockItem.rawValue && nodeParent.parent != nil {
    guard let parent = nodeParent.parent else { break }
    nodeParent = parent
  }

  guard nodeParent.text == type else {
    throw GraphWalkersError.noParent
  }

  return nodeParent
}

var count = 0

func getFirstChildOf(type: String, in node: Node) throws -> Node {
  for child in node.children {
    if child.text == type {
      return child
    }
  }

  for child in node.children {
    do {
      let firstChild = try getFirstChildOf(type: type, in: child)
      return firstChild
    } catch {
      throw error
    }
  }

  throw GraphWalkersError.noChild
}
