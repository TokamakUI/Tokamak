//
//  RenderGetsHooksRule.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 5/6/19.
//

import Foundation
import SwiftSyntax

struct RenderGetsHooksRule: Rule {
  public static let description = RuleDescription(
    type: RenderGetsHooksRule.self,
    name: "Render gets Hooks",
    description: "Non-pure render should gets Hooks type argument"
  )

  public static func validate(visitor: TokenVisitor) -> [StyleViolation] {
    guard let renderFunction = render(from: visitor.root, at: visitor.path) else { return [StyleViolation(
        ruleDescription: OneRenderFunctionRule.description,
        location: Location(
            file: visitor.path,
            line: visitor.root.range.startRow,
            character: visitor.root.range.startColumn
        )
        )] }
    guard let codeBlock = parent(of: SyntaxKind.codeBlockItem.rawValue, in: renderFunction) else { return [StyleViolation(
        ruleDescription: OneRenderFunctionRule.description,
        location: Location(
            file: visitor.path,
            line: renderFunction.range.startRow,
            character: renderFunction.range.startColumn
        )
        )] }
    guard let functionSignature = firstChild(of: SyntaxKind.functionSignature.rawValue, in: codeBlock) else { return [] }

    let hooksArgemnt = functionSignature.getNodes(with: SyntaxKind.simpleTypeIdentifier.rawValue).filter {
      guard !$0.children.isEmpty, let children = $0.children.first else { return false }
      return children.text == "Hooks"
    }

    guard !hooksArgemnt.isEmpty else {
      return [StyleViolation(
        ruleDescription: OneRenderFunctionRule.description,
        location: Location(
          file: visitor.path,
          line: renderFunction.range.startRow,
          character: renderFunction.range.startColumn
        )
      )]
    }
    return []
  }
}
