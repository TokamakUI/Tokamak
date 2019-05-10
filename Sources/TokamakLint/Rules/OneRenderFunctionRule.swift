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

  static func validate(visitor: TokenVisitor) -> [StyleViolation] {
    do {
      let render = try getRender(from: visitor.root, at: visitor.path)
    } catch let error as [StyleViolation] {
      return error
    } catch {
      print(error)
      return []
    }
    return []
  }
}
