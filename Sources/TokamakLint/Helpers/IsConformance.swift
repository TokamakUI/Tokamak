//
//  IsNodeConformanceToProtocol.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 5/8/19.
//

import Foundation
import SwiftSyntax

func isCodeBlockItemConformace(node: Node, at path: String) throws -> Bool {
  let renderWithHooksProtocols = ["CompositeComponent", "LeafComponent"]

  let codeBlockItem = try getParentOf(type: SyntaxKind.codeBlockItem.rawValue, in: node)

  let typeInheritanceClause = try getFirstChildOf(
    type: SyntaxKind.typeInheritanceClause.rawValue,
    in: codeBlockItem
  )

  let types = typeInheritanceClause.getNodes(with: SyntaxKind.simpleTypeIdentifier.rawValue)

  return types.contains {
    guard let child = $0.children.first else { return false }
    return renderWithHooksProtocols.contains(child.text)
  }
}
