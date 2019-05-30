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

    // search render function
    let structs = visitor.root.components(hookedComponentProtocols)

    structs.forEach { structDecl in
      for render in structDecl.children(with: "render") {
        // search Hooks argument name in the render argument list
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

        // check that the Hooks.state is on the first layer of the render function
        hooks.forEach { hook in
          guard let hookMemberAccessExpr = hook
            .firstParent(of: .memberAccessExpr),
            let hookCodeBlockItem = hookMemberAccessExpr
            .firstParent(of: .codeBlockItem),
            !codeBlockItemList.children.contains(hookCodeBlockItem)
          else { return }
          violations.append(StyleViolation(
            ruleDescription: HooksRule.description,
            location: Location(
              file: visitor.path,
              line: hook.range.startRow,
              character: hook.range.startColumn
            )
          ))
        }
      }
    }

    // search Hooks extension
    let extensions = visitor.root.children(with: .extensionDecl)
      .filter { ext in
        let simpleTypeIdentifier = ext.firstChild(of: .simpleTypeIdentifier)
        return simpleTypeIdentifier?.children[0].text == "Hooks"
      }

    extensions.forEach { ext in
      // search all memberDeclListItem
      guard let memberDeclList = ext.firstChild(of: .memberDeclList) else {
        return
      }
      memberDeclList.children.forEach { memberDeclListItem in
        // search `state` use in memberDeclListItem
        // FIXME: this should be extended on all possible hooks, not only `state`
        let states = memberDeclListItem.children(with: "state")

        // search codeBlockItemList in memberDeclListItem
        guard let memberCodeBlockItemList = memberDeclList.firstChild(of: .codeBlockItemList) else { return }

        states.forEach { state in
          let stateCodeBlock = state.firstParent(of: .codeBlockItem)
          guard let safeState = stateCodeBlock else { return }
          guard memberCodeBlockItemList.children.contains(safeState) else {
            violations.append(
              StyleViolation(
                ruleDescription: HooksRule.description,
                location: Location(
                  file: visitor.path,
                  line: state.range.startRow,
                  character: state.range.startColumn
                )
              )
            )
            return
          }
        }
      }
    }

    return violations
  }
}
