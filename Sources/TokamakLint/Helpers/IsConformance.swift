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

  guard let codeBlockItem = parent(of: SyntaxKind.codeBlockItem.rawValue, in: node) else { return false }

  let typeInheritanceClause = firstChild(
    of: SyntaxKind.typeInheritanceClause.rawValue,
    in: codeBlockItem
  )

  guard types = typeInheritanceClause.getNodes(with: SyntaxKind.simpleTypeIdentifier.rawValue) else { return false }

  return types.contains {
    guard let child = $0.children.first else { return false }
    return renderWithHooksProtocols.contains(child.text)
  }
}
