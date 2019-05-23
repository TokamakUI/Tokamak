//
//  GetHookedComponents.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 5/23/19.
//

import SwiftSyntax

extension Node {
  /// return Tokamak components that can have hooks in the render
  /// placed as a children of node
  var hookedComponents: [Node] {
    return children(with: "struct")
      .compactMap { $0.firstParent(of: SyntaxKind.structDecl.rawValue) }
      .filter { structDecl in
        let hookedProtocols = ["CompositeComponent", "LeafComponent"]
        guard let typeInheritanceClause = structDecl.firstChild(
          of: SyntaxKind.typeInheritanceClause.rawValue
        ) else { return false }
        let types = typeInheritanceClause.children(
          with: SyntaxKind.simpleTypeIdentifier.rawValue
        ).compactMap { $0.children.first?.text }
        return types.contains { hookedProtocols.contains($0) }
      }
  }
}
