//
//  File.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 4/9/19.
//

import Foundation
import SwiftSyntax

struct PropsIsEquatableRule: Rule {
  public static let description = RuleDescription(
    type: PropsIsEquatableRule.self,
    name: "Props is Equatable",
    description: "Component Props type should conform to Equatable protocol"
  )

  public static func validate(visitor: TokenVisitor) -> [StyleViolation] {
    var violations: [StyleViolation] = []
    let structs = visitor.root.children(with: SyntaxKind.structDecl.rawValue)
    for structNode in structs {
      // sometimes there are additional children `ModifierList`
      // it will be better to filter array to find out if struct name is
      // `Props`
      let propsNodes = structNode.children.filter { (node) -> Bool in
        node.text == "Props"
      }
      guard propsNodes.count != 0 else { continue }
      let propsNode = propsNodes[0]

      guard let propsParent = propsNode.parent, !propsParent.isInherited(
        from: "Equatable"
      ) else { continue }
      violations.append(
        StyleViolation(
          ruleDescription: description,
          location: Location(
            file: visitor.path,
            line: propsNode.range.startRow,
            character: propsNode.range.startColumn
          )
        )
      )
    }

    // remove repeated StyleViolation
    // because of walk algorithm that visit nested node several times
    var uniqueViolations: [StyleViolation] = []
    for violation in violations {
      if !uniqueViolations.contains(where: { v in
        v.location.line == violation.location.line
      }) {
        uniqueViolations.append(violation)
      }
    }
    return uniqueViolations
  }
}
