//
//  OneRenderFunctionRule.swift
//  TokamakCLI
//
//  Created by Matvii Hodovaniuk on 5/6/19.
//

import Foundation
import SwiftSyntax

struct OneRenderFunctionRule: Rule {
  public static let description = RuleDescription(
    type: OneRenderFunctionRule.self,
    name: "One Render Function",
    description: "The component should have only one render function"
  )

  public static func validate(visitor: TokenVisitor) -> [StyleViolation] {
    let renders = visitor.getNodes(with: "render", from: visitor.root)

    guard renders.count > 1, let file = visitor.path else { return [] }

    return renders.map {
      StyleViolation(
        ruleDescription: description,
        location: Location(
          file: file,
          line: $0.range.startRow,
          character: $0.range.startColumn
        )
      )
    }
  }
}
