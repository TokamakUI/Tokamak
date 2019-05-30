//
//  ComponentIsStructRule.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 5/30/19.
//

import SwiftSyntax

struct ComponentIsStructRule: Rule {
  static let description = RuleDescription(
    type: ComponentIsStructRule.self,
    name: "Component as struct",
    description: "Components can only be declared as structs"
  )

  public static func validate(visitor: TokenVisitor) -> [StyleViolation] {
    var violations: [StyleViolation] = []

    // search usage of componentProtocols
    componentProtocols.forEach { prot in
      let components = visitor.root.children(with: prot)
      components.forEach { component in

        // check that components is struct
        guard let componentCodeBlockItem = component.firstParent(of: .codeBlockItem) else { return }
        guard componentCodeBlockItem.children.first?.text == SyntaxKind.structDecl.rawValue else {
          violations.append(StyleViolation(
            ruleDescription: ComponentIsStructRule.description,
            location: Location(
              file: visitor.path,
              line: componentCodeBlockItem.range.startRow,
              character: componentCodeBlockItem.range.startColumn
            )
          ))
          return
        }
      }
    }

    return violations
  }
}
