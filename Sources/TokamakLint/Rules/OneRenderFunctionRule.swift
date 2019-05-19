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
      _ = try visitor.root.getOneRender(at: visitor.path)
    } catch let error as [StyleViolation] {
      return error
    } catch {
      print(error)
      return []
    }
    return []
  }
}
