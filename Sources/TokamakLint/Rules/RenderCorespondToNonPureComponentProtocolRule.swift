//
//  RenderCorespondToNonPureComponentProtocolRule.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 5/6/19.
//

import Foundation
import SwiftSyntax

struct RenderCorespondToNonPureComponentProtocolRule: Rule {
  public static let description = RuleDescription(
    type: RenderCorespondToNonPureComponentProtocolRule.self,
    name: "Render corespond to non-pure component protocol",
    description: "Non-pure render function should corespond to non-pure component protocol"
  )

  public static func validate(visitor: TokenVisitor) -> [StyleViolation] {
    var violations: [StyleViolation] = []
    var isInheritance = false
    let nonPureComponentsType = ["AnyCompositeComponent", "CompositeComponent", "LeafComponent", "PureLeafComponent"]

    // alternative way is to get list of codeblocks and search for block
    // that contain render function

    let renders = visitor.getNodes(get: "render", from: visitor.tree[0])

    let render = renders[0]

    let component = render.parent?.parent?.parent?.parent?.parent

    guard let TypeInheritanceClause = component?.children[2] else {
      // should be better value to return
      return violations
    }

    let types = visitor.getNodes(get: "SimpleTypeIdentifier", from: TypeInheritanceClause)

    for type in types {
      if nonPureComponentsType.contains(type.children[0].text) {
        isInheritance = true
        break
      }
    }

    if !isInheritance {
      violations.append(
        // remove force unwrap
        StyleViolation(
          ruleDescription: description,
          location: Location(
            file: visitor.path ?? "",
            line: (component?.range.startRow)!,
            character: (component?.range.startColumn)!
          )
        )
      )
    }

    return violations
  }
}
