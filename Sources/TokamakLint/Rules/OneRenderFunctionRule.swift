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
        .filter { (structDecl) in
          let hookedProtocols = ["CompositeComponent", "LeafComponent"]
          guard let typeInheritanceClause = structDecl.firstChild(
            of: SyntaxKind.typeInheritanceClause.rawValue
          ) else { return false }
          let types = typeInheritanceClause.children(
            with: SyntaxKind.simpleTypeIdentifier.rawValue
          ).map { (node) -> String in
            guard let typeNameNode = node.children.first else { return "" }
            return typeNameNode.text
          }
          guard types.contains(where: { (type) in
            hookedProtocols.contains(type)
          }) else { return false }
          return true
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
