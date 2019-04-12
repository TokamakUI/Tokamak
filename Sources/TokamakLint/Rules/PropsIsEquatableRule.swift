//
//  File.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 4/9/19.
//

import Foundation
import SwiftSyntax

public struct PropsIsEquatableRule: Rule {
  public init() {}

  public static let description = RuleDescription(
    identifier: "props_is_equatable",
    name: "Props is Equatable",
    description: "Component Props type shoud conformance to Equatable protocol"
  )

  public static func validate(visitor: TokenVisitor) -> [StyleViolation] {
    var violations: [StyleViolation] = []
    let structs = visitor.getNodes(get: "StructDecl", from: visitor.tree[0])
    for structNode in structs {
      let propsDecl = visitor.getNodes(get: "Props", from: structNode)
      guard propsDecl.count > 0 else { continue }

      for propsNode in propsDecl {
        guard let propsParent = propsNode.parent, !visitor.isInherited(
          node: propsParent,
          from: "Equatable"
        ) else { continue }
        violations.append(
          StyleViolation(
            ruleDescription: description,
            location: Location(
              file: visitor.path ?? "",
              line: propsNode.range.startRow,
              character: propsNode.range.startColumn
            )
          )
        )
      }
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
