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

    do {
      // search for render function
      let structs = visitor.root.components(hookedComponentProtocols)
        
      try structs.forEach { _ in
        let renderFunction = try visitor.root.getOneRender(at: visitor.path)
        guard let codeBlock = renderFunction.firstParent(
          of: SyntaxKind.codeBlockItem.rawValue
        ) else {
          violations.append(StyleViolation(
            ruleDescription: OneRenderFunctionRule.description,
            location: Location(
              file: visitor.path,
              line: renderFunction.range.startRow,
              character: renderFunction.range.startColumn
            )
          ))
          return
        }
        guard let functionSignature = codeBlock.firstChild(
          of: SyntaxKind.functionSignature.rawValue
        ) else { return }

        let hooksArgument = functionSignature.children(
          with: SyntaxKind.simpleTypeIdentifier.rawValue
        ).filter { $0.children.first? .text == "Hooks" }

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
    } catch let error as [StyleViolation] {
      return error
    } catch {
      print(error)
    }

    return []
  }
}
