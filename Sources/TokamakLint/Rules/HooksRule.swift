//
//  HooksRule.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 5/21/19.
//

import SwiftSyntax

struct HooksRule: Rule {
  static let description = RuleDescription(
    type: HooksRule.self,
    name: "Rules of Hooks",
    description: "Use hooks on top level of render"
  )

  public static func validate(visitor: TokenVisitor) -> [StyleViolation] {
    var violations: [StyleViolation] = []

    // search for render function
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
    structs.forEach { structDecl in
      for render in structDecl.children(with: "render") {
        // search for Hooks argument name in render argument list
        let renderFuncDecl = render.firstParent(of: .functionDecl)
        let funcSign = renderFuncDecl?.firstChild(of: .functionSignature)
        let funcParameterList = funcSign?
          .firstChild(of: .functionParameterList)
        let hooksParameter = funcParameterList?.firstChild(of: "Hooks")?
          .firstParent(of: .functionParameter)
        guard let hooksName = hooksParameter?.children.first?.text
        else { return }

        // search for all hooks in code
        guard let hooks = renderFuncDecl?.children(with: hooksName)
        else { return }

        // check that Hooks.state is on the first layer of render function
        guard let codeBlockItemList = renderFuncDecl?
          .firstChild(of: .codeBlockItemList)
        else { return }
        hooks.forEach { hook in
          guard let hookMemberAccessExpr = hook
            .firstParent(of: .memberAccessExpr)
          else { return }
          guard let hookCodeBlockItem = hookMemberAccessExpr
            .firstParent(of: .codeBlockItem)
          else { return }
          guard !codeBlockItemList.children.contains(hookCodeBlockItem)
          else { return }
          violations.append(StyleViolation(
            ruleDescription: OneRenderFunctionRule.description,
            location: Location(
              file: visitor.path,
              line: hook.range.startRow,
              character: hook.range.startColumn
            )
          ))
        }
      }
    }

    return violations
  }
}
