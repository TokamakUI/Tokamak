//
//  TokamakLint.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 4/1/19.
//

import Foundation
import SwiftSyntax

public func lintFile(_ path: String) throws -> [StyleViolation] {
  let visitor = try walkParsedTree(path)
  visitor.path = path
  guard !hasTokamakImport(from: visitor) else {
    return []
  }
  return PropsIsEquatableRule.validate(visitor: visitor)
}

private func walkParsedTree(_ path: String) throws -> TokenVisitor {
  let fileURL = URL(fileURLWithPath: path)
  let parsedTree = try SyntaxTreeParser.parse(fileURL)
  let visitor = TokenVisitor()
  visitor.path = path
  parsedTree.walk(visitor)
  return visitor
}

private func isSwiftFile(_ path: String) -> Bool {
  return path.contains(".swift")
}

private func hasTokamakImport(from visitor: TokenVisitor) -> Bool {
  var doesTokamakImportExist = false
  let imports = visitor.getNodes(get: "ImportDecl", from: visitor.tree[0])
  for importNode in imports {
    let importModules = visitor.getNodes(get: "AccessPathComponent", from: importNode)
    for module in importModules where module.children[0].text == "Tokamak" {
      doesTokamakImportExist = true
    }
  }

  return doesTokamakImportExist
}
