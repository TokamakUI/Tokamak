//
//  OneRenderFunctionRule.swift
//  TokamakCLI
//
//  Created by Matvii Hodovaniuk on 5/6/19.
//

import SwiftSyntax

struct OneRenderFunctionRule: Rule {
  static let description = RuleDescription(
    type: OneRenderFunctionRule.self,
    name: "One Render Function",
    description: "The component should have only one render function"
  )

  static func validate(visitor: TokenVisitor) -> [StyleViolation] {
    do {
      let structs = visitor.root.children(with: "struct")
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

      guard !structs.isEmpty else { return [] }

      var violations: [StyleViolation] = []

      try structs.forEach { structDecl in
        do {
          _ = try structDecl.getOneRender(at: visitor.path)
        } catch let error as [StyleViolation] {
          violations.append(contentsOf: error)
        } catch {
          throw error
        }
      }
      guard violations.isEmpty else {
        throw violations
      }
    } catch let error as [StyleViolation] {
      return error
    } catch {
      print(error)
    }
    return []
  }
}
