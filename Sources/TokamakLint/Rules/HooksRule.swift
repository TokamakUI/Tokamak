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
    let structs = visitor.root.components(hookedComponentProtocols)

    structs.forEach { structDecl in
      for render in structDecl.children(with: "render") {
        // search for Hooks argument name in the render argument list
        let renderFuncDecl = render.firstParent(of: .functionDecl)
        let funcSign = renderFuncDecl?.firstChild(of: .functionSignature)
        let funcParameterList = funcSign?
          .firstChild(of: .functionParameterList)
        let hooksParameter = funcParameterList?.firstChild(of: "Hooks")?
          .firstParent(of: .functionParameter)
        guard let hooksName = hooksParameter?.children.first?.text,
          let hooks = renderFuncDecl?.children(with: hooksName),
          let codeBlockItemList = renderFuncDecl?
          .firstChild(of: .codeBlockItemList)
        else { return }

        // check that Hooks.state is on the first layer of the render function
        hooks.forEach { hook in
          guard let hookMemberAccessExpr = hook
            .firstParent(of: .memberAccessExpr),
            let hookCodeBlockItem = hookMemberAccessExpr
            .firstParent(of: .codeBlockItem),
            !codeBlockItemList.children.contains(hookCodeBlockItem)
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
