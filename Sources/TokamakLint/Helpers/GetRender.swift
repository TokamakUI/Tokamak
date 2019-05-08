//
//  GetRender.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 5/8/19.
//

import Foundation
import SwiftSyntax

extension Array: Error where Element == StyleViolation {}

func getRender(from node: Node, at file: String) throws -> Node {
  let renders = node.getNodes(with: "render").filter {
    // check if render type is function
    var memberDeclListItem = $0
    while memberDeclListItem.text != "MemberDeclListItem"
      && memberDeclListItem.parent != nil {
      guard let parent = memberDeclListItem.parent else { break }
      memberDeclListItem = parent
    }
    guard memberDeclListItem.children[0].text
      == TokenDeclType.function.rawValue else { return false }

    // check if render is static
    let staticModifier = memberDeclListItem.getNodes(
      with: "DeclModifier"
    ).filter {
      guard let child = $0.children.first else { return false }
      return child.text == "static"
    }
    guard staticModifier.first != nil else { return false }

    // check if render is on first layer of component
    let firstLayerCildrens = memberDeclListItem.children[0].children.map {
      $0.text
    }
    guard firstLayerCildrens.contains("render") else { return false }

    return true
  }

  guard renders.count == 1 else {
    if renders.count > 1 {
      throw renders.map {
        StyleViolation(
          ruleDescription: OneRenderFunctionRule.description,
          location: Location(
            file: file,
            line: $0.range.startRow,
            character: $0.range.startColumn
          )
        )
      }
    } else {
      throw [StyleViolation(
        ruleDescription: OneRenderFunctionRule.description,
        location: Location(
          file: file,
          line: node.range.startRow,
          character: node.range.startColumn
        )
      )]
    }
  }

  return renders[0]
}
