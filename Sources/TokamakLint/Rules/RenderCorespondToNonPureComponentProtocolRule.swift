//
//  RenderCorespondToNonPureComponentProtocolRule.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 5/6/19.
//

import Foundation
import SwiftSyntax

enum TokenDeclType: String {
  case structure = "StructDecl"
  case function = "FunctionDecl"
  case variable = "VariableDecl"
}

struct RenderCorespondToNonPureComponentProtocolRule: Rule {
  public static let description = RuleDescription(
    type: RenderCorespondToNonPureComponentProtocolRule.self,
    name: "Render corespond to non-pure component protocol",
    description: "Non-pure render function should corespond to non-pure component protocol"
  )

  public static func validate(visitor: TokenVisitor) -> [StyleViolation] {
    var violations: [StyleViolation] = []
    var isConforming = false
    let renderWithHooksProtocols = ["CompositeComponent", "LeafComponent"]

    // alternative way is to get list of codeblocks and search for block
    // that contain render function

    let renders = visitor.getNodes(get: "render", from: visitor.tree[0]).filter {
      // check if render type if function

      var memberDeclListItem: Node = $0

      while memberDeclListItem.text != "MemberDeclListItem" && memberDeclListItem.parent != nil {
        guard let parent = memberDeclListItem.parent else { break }
        memberDeclListItem = parent
      }

      guard memberDeclListItem.children[0].text == TokenDeclType.function.rawValue else { return false }

      // check if render is static

      let staticModifier = visitor.getNodes(get: "DeclModifier", from: memberDeclListItem).filter { (modifier) -> Bool in
        modifier.children[0].text == "static"
      }

      guard staticModifier.first != nil else { return false }

      // check if render is on first layer of component

      let firstLayerCildrens = memberDeclListItem.children[0].children.map {
        $0.text
      }

      guard firstLayerCildrens.contains("render") else { return false }

      return true
    }

    guard renders.count == 1 else { return [StyleViolation(
      ruleDescription: description,
      location: Location(
        file: visitor.path ?? "",
        line: 0,
        character: 0
      )
    )] }

    var codeBlockItem: Node = renders[0]

    while codeBlockItem.text != "CodeBlockItem" && codeBlockItem.parent != nil {
      guard let parent = codeBlockItem.parent else { break }
      codeBlockItem = parent
    }

    let typeInheritanceClause = codeBlockItem.children[0].children[2]

    let types = visitor.getNodes(get: "SimpleTypeIdentifier", from: typeInheritanceClause)

    for type in types {
      if renderWithHooksProtocols.contains(type.children[0].text) {
        isConforming = true
        break
      }
    }

    if !isConforming {
      violations.append(
        StyleViolation(
          ruleDescription: description,
          location: Location(
            file: visitor.path ?? "",
            line: codeBlockItem.range.startRow,
            character: codeBlockItem.range.startColumn
          )
        )
      )
    }

    return violations
  }
}
