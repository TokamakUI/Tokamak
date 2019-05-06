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
    var violations: [StyleViolation] = []

    let renders = visitor.getNodes(get: "render", from: visitor.tree[0])

    if renders.count > 1 {
      for render in renders {
        violations.append(
          StyleViolation(
            ruleDescription: description,
            location: Location(
              file: visitor.path ?? "",
              line: render.range.startRow,
              character: render.range.startColumn
            )
          )
        )
      }
    }

    return violations
  }
}
