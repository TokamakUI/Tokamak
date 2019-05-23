//
//  OneRenderFunctionRule.swift
//  TokamakCLI
//
//  Created by Matvii Hodovaniuk on 5/6/19.
//

import SwiftSyntax

struct OneRenderFunctionRule: Rule {
  static let description = RuleDescription(
    type: OneRenderFunctionRule.self,
    name: "One Render Function",
    description: "The component should have only one render function"
  )

  static func validate(visitor: TokenVisitor) -> [StyleViolation] {
    do {
      let structs = visitor.root.hookedComponents()

      guard !structs.isEmpty else { return [] }

      var violations: [StyleViolation] = []

      try structs.forEach { structDecl in
        do {
          _ = try structDecl.getOneRender(at: visitor.path)
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
