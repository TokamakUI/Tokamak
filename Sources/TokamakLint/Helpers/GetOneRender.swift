//
//  GetRender.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 5/8/19.
//

import Foundation
import SwiftSyntax

extension Array: Error where Element == StyleViolation {}

extension Node {
  func getOneRender(at file: String) throws -> Node {
    // search for renders in file
    let renders = children(with: "render").filter {
      // check if render type is function
      var memberDeclListItem = $0
      while memberDeclListItem.text != SyntaxKind.memberDeclListItem.rawValue
        && memberDeclListItem.parent != nil {
        guard let parent = memberDeclListItem.parent else { break }
        memberDeclListItem = parent
      }
      guard let functionDecl = memberDeclListItem.children.first,
        functionDecl.text == SyntaxKind.functionDecl.rawValue else { return false }

      // check if render is static
      let staticModifier = memberDeclListItem.children(
        with: SyntaxKind.declModifier.rawValue
      ).filter {
        guard let child = $0.children.first else { return false }
        return child.text == "static"
      }
      guard staticModifier.first != nil else { return false }

      // check if render in host component
      let hostProtocols = ["CompositeComponent", "LeafComponent"]
      guard let structDecl = memberDeclListItem.firstParent(
        of: SyntaxKind.structDecl.rawValue
      ) else { return false }
      guard let typeInheritanceClause = structDecl.firstChild(
        of: SyntaxKind.typeInheritanceClause.rawValue
      ) else { return false }
      let types = typeInheritanceClause.children(
        with: SyntaxKind.simpleTypeIdentifier.rawValue
      ).map { (node) -> String in
        guard let typeNameNode = node.children.first else { return "" }
        return typeNameNode.text
      }
      guard types.contains(where: { (type) -> Bool in
        hostProtocols.contains(type)
      }) else { return false }

      // check if render is on first layer of component
      return functionDecl.children.map {
        $0.text
      }.contains("render")
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
            line: self.range.startRow,
            character: self.range.startColumn
          )
        )]
      }
    }

    return renders[0]
  }
}
