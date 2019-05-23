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
    description: "Code need to follow rules of hooks"
  )

  public static func validate(visitor: TokenVisitor) -> [StyleViolation] {
    // search for render function
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
          let render = try structDecl.getOneRender(at: visitor.path)

          // search for Hooks argument name in render argument list
          guard let renderFuncDecl = render.firstParent(of: .functionDecl) else { throw [] }
          let funcSign = renderFuncDecl.firstChild(of: .functionSignature)
          let funcParameterList = funcSign?.firstChild(of: .functionParameterList)
          let hooksParameter = funcParameterList?.firstChild(of: "Hooks")?.firstParent(of: .functionParameter)
          guard let hooksName = hooksParameter?.children.first?.text else { throw [] }

          // search for all hooks in code
          let hooks = renderFuncDecl.children(with: hooksName)

          // check that Hooks.state is on the first layer of render function
          guard let codeBlockItemList = renderFuncDecl.firstChild(of: .codeBlockItemList) else { throw [] }

          throw hooks.compactMap { (hook) -> StyleViolation? in
            guard let hookMemberAccessExpr = hook.firstParent(of: .memberAccessExpr) else { return nil }
            guard let hookCodeBlockItem = hookMemberAccessExpr.firstParent(of: .codeBlockItem) else { return nil }
            guard codeBlockItemList.children.contains(hookCodeBlockItem) else { return StyleViolation(
              ruleDescription: OneRenderFunctionRule.description,
              location: Location(
                file: visitor.path,
                line: hook.range.startRow,
                character: hook.range.startColumn
              )
            ) }
            return nil
          }
        } catch let error as [StyleViolation] {
          violations.append(contentsOf: error)
        } catch {
          throw error
        }
      }
      return violations
    } catch {
      print(error)
    }
    return []
  }
}
