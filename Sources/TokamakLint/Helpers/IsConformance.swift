//
//  IsNodeConformanceToProtocol.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 5/8/19.
//

import Foundation
import SwiftSyntax

func isConformace(node: Node, to protocol: String, at path: String) throws -> Bool {
  var isConforming = false
  let renderWithHooksProtocols = ["CompositeComponent", "LeafComponent"]

  var codeBlockItem = try getRender(from: node, at: path)

  while codeBlockItem.text != SyntaxKind.codeBlockItem.rawValue && codeBlockItem.parent != nil {
    guard let parent = codeBlockItem.parent else { break }
    codeBlockItem = parent
  }

  let typeInheritanceClause = codeBlockItem.children[0].children[2]

  let types = typeInheritanceClause.getNodes(with: SyntaxKind.simpleTypeIdentifier.rawValue)

  for type in types {
    if renderWithHooksProtocols.contains(type.children[0].text) {
      isConforming = true
      break
    }
  }

  return isConforming
}
