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
    parsedTree.walk(visitor)
    return validate(visitor: visitor)
  }

  public static func validate(visitor: TokenVisitor) -> [StyleViolation] {
    var violations: [StyleViolation] = []
    let structs = visitor.getNodes(get: "StructDecl", from: visitor.tree[0])
    for structNode in structs {
      // should i use guard?
      if !visitor.isInherited(
        node: structNode,
        from: "Equatable"
      ) {
        violations.append(
          StyleViolation(
            ruleDescription: description,
            location: Location(
              file: "",
              line: structNode.range.startRow,
              character: structNode.range.startColumn
            )
          )
        )
      }
    }

    return violations
  }
}
