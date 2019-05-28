//
//  GetComponents.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 5/28/19.
//

import SwiftSyntax

let hookedComponentProtocols = ["CompositeComponent", "LeafComponent"]
let componentsProtocols = ["CompositeComponent", "LeafComponent",
                           "PureLeafComponent", "PureComponent"]

extension Node {
  /// return Tokamak components that can have hooks in the render
  /// placed as a children of node
  func components(_ protocols: [String]) -> [Node] {
    return children(with: "struct")
      .compactMap { $0.firstParent(of: SyntaxKind.structDecl.rawValue) }
      .filter { structDecl in
        guard let typeInheritanceClause = structDecl.firstChild(
          of: SyntaxKind.typeInheritanceClause.rawValue
        ) else { return false }
        let types = typeInheritanceClause.children(
          with: SyntaxKind.simpleTypeIdentifier.rawValue
        ).compactMap { $0.children.first?.text }
        return types.contains { protocols.contains($0) }
      }
  }
}
