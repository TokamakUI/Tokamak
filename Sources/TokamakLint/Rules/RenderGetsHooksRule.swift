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
    do {
      let renderFunction = try visitor.root.getOneRender(at: visitor.path)
      guard let codeBlock = renderFunction.firstParent(
        of: SyntaxKind.codeBlockItem.rawValue
      ) else { return [StyleViolation(
        ruleDescription: OneRenderFunctionRule.description,
        location: Location(
          file: visitor.path,
          line: renderFunction.range.startRow,
          character: renderFunction.range.startColumn
        )
      )] }
      guard let functionSignature = codeBlock.firstChild(
        of: SyntaxKind.functionSignature.rawValue
      ) else { return [] }

      let hooksArgument = functionSignature.children(
        with: SyntaxKind.simpleTypeIdentifier.rawValue
      ).filter {
        guard let children = $0.children.first else { return false }
        return children.text == "Hooks"
      }

      guard !hooksArgument.isEmpty else {
        return [StyleViolation(
          ruleDescription: OneRenderFunctionRule.description,
          location: Location(
            file: visitor.path,
            line: renderFunction.range.startRow,
            character: renderFunction.range.startColumn
          )
        )]
      }
    } catch let error as [StyleViolation] {
      return error
    } catch {
      print(error)
    }

    return []
  }
}
