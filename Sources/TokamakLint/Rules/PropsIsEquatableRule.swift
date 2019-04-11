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

  public static func validate(path: String) throws -> [StyleViolation] {
    let fileURL = URL(fileURLWithPath: path)
    let parsedTree = try SyntaxTreeParser.parse(fileURL)
    let visitor = TokenVisitor()
    visitor.path = path
    parsedTree.walk(visitor)
    return validate(visitor: visitor)
  }

  public static func validate(visitor: TokenVisitor) -> [StyleViolation] {
    var violations: [StyleViolation] = []
    let structs = visitor.getNodes(get: "StructDecl", from: visitor.tree[0])
    for structNode in structs {
      // should it be with guard?
      let propsDecl = visitor.getNodes(get: "Props", from: structNode)
      if propsDecl.count > 0 {
        for decl in propsDecl {
          if !visitor.isInherited(
            node: decl,
            from: "Equatable"
          ) {
            violations.append(
              StyleViolation(
                ruleDescription: description,
                location: Location(
                  file: visitor.path ?? "",
                  line: structNode.range.startRow,
                  character: structNode.range.startColumn
                )
              )
            )
          }
        }
      }
    }

    // remove repeated StyleViolation
    // because of walk algorithm that visit nested node several times
    var unicViolations: [StyleViolation] = []
    for violation in violations {
      if !unicViolations.contains(where: { v in
        if v.location.line == violation.location.line {
          return true
        } else {
          return false
        }
      }) {
        unicViolations.append(violation)
      }
    }
    return unicViolations
  }
}
