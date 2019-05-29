//
//  RenderGetsHooksRule.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 5/6/19.
//

import SwiftSyntax

struct RenderGetsHooksRule: Rule {
  static let description = RuleDescription(
    type: RenderGetsHooksRule.self,
    name: "Render gets Hooks",
    description: "Non-pure render should get Hooks type argument"
  )

  public static func validate(visitor: TokenVisitor) -> [StyleViolation] {
    var violations: [StyleViolation] = []

    // search for components declaration
    let structs = visitor.root.components(hookedComponentProtocols)
    structs.forEach { structDecl in

      // search for render functions
      for renderFunction in structDecl.children(with: "render") {
        // search for renderCodeBlock
        guard let codeBlock = renderFunction.firstParent(
          of: SyntaxKind.codeBlockItem
        ) else { return }

        // search for render function signature
        guard let functionSignature = codeBlock.firstChild(
          of: SyntaxKind.functionSignature
        ) else { return }

        // search for Hooks in render arguments list
        let hooksArgument = functionSignature.children(
          with: SyntaxKind.simpleTypeIdentifier
        ).filter { $0.children.first?.text == "Hooks" }

        // check if render arguments list contains argument of type Hooks
        guard !hooksArgument.isEmpty else {
          violations.append(StyleViolation(
            ruleDescription: RenderGetsHooksRule.description,
            location: Location(
              file: visitor.path,
              line: renderFunction.range.startRow,
              character: renderFunction.range.startColumn
            )
          ))
          return
        }
      }
    }

    return violations
  }
}
