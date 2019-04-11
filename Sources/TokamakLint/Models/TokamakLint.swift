//
//  TokamakLint.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 4/1/19.
//

import Foundation
import SwiftSyntax

public func lintFolder(_ path: String) throws {
//  let resourceKeys: [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
//  let baseurl = URL(fileURLWithPath: path)
//  guard let enumerator = FileManager
//    .default
//    .enumerator(at: baseurl,
//                includingPropertiesForKeys: resourceKeys,
//                options: [.skipsHiddenFiles],
//                errorHandler: { (url, error) -> Bool in
//                  print("directoryEnumerator error at \(url): ", error)
//                  return true
//    })?.compactMap({ $0 as? URL }).filter({ isSwiftFile($0.path) })
//  else {
//    fatalError("Enumerator is nil")
//  }
//  let count = enumerator.count
//  let enumerated = enumerator.enumerated()
//  for (i, fileURL) in enumerated {
//    print("Linting ",
//          "\(fileURL.lastPathComponent) ",
//          "(\(i)/\(count))")
//    let visitor = try walkParsedTree(fileURL.path)
//    if hasTokamakImport(from: visitor) {
//      guard try isPropsEquatable(fileURL.path) else {
//        throw LintError.propsIsNotEquatable
//      }
//    }
//  }
}

public func lintFile(_ path: String) throws -> [StyleViolation] {
  let visitor = try walkParsedTree(path)
  guard !hasTokamakImport(from: visitor) else {
    return []
  }
  var errors: [StyleViolation] = []
  errors.append(contentsOf: PropsIsEquatableRule.validate(visitor: visitor))
  return errors
}

private func walkParsedTree(_ path: String) throws -> TokenVisitor {
  let fileURL = URL(fileURLWithPath: path)
  let parsedTree = try SyntaxTreeParser.parse(fileURL)
  let visitor = TokenVisitor()
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

// private func lintInheritance(_ path: String) -> [String] {
//  let structs = visitor.getNodes(get: "StructDecl", from: visitor.tree[0])
//  for structNode in structs {
//    guard visitor.isInherited(
//      node: structNode,
//      from: "Equatable"
//    ) else {
//      errors.append(LintError.propsIsNotEquatable)
//    }
//  }
// }
