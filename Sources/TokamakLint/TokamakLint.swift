//
//  TokamakLint.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 4/1/19.
//

import Foundation
import SwiftSyntax

public func lintFolder(_ path: String) throws {
  let resourceKeys: [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
  let baseurl = URL(fileURLWithPath: path)
  guard let enumerator = FileManager
    .default
    .enumerator(at: baseurl,
                includingPropertiesForKeys: resourceKeys,
                options: [.skipsHiddenFiles],
                errorHandler: { (url, error) -> Bool in
                  print("directoryEnumerator error at \(url): ", error)
                  return true
    })?.compactMap({ $0 as? URL }).filter({ isSwiftFile($0.path) })
  else {
    fatalError("Enumerator is nil")
  }
  let count = enumerator.count
  let enumerated = enumerator.enumerated()
  for (i, fileURL) in enumerated {
    print("Linting ",
          "\(fileURL.lastPathComponent) ",
          "(\(i)/\(count))")
    let visitor = try walkParsedTree(fileURL.path)
    if hasTokamakImport(from: visitor) {
      try isPropsEquatable(fileURL.path)
    }
  }
}

public func lintFile(_ path: String) throws {
  let visitor = try walkParsedTree(path)
  if hasTokamakImport(from: visitor) {
    let structs = visitor.getNodes(get: "StructDecl", from: visitor.tree[0])
    for structNode in structs {
      let isInherited = visitor.isInherited(
        node: structNode,
        from: "Equatable"
      )
    }
  }
}

public func isPropsEquatable(_ path: String) throws -> Bool {
  var res: Bool = false
  let visitor = try walkParsedTree(path)
  let structs = visitor.getNodes(get: "StructDecl", from: visitor.tree[0])
  for structNode in structs where structNode.children[1].text == "Props" {
    res = visitor.isInherited(node: structNode, from: "Equatable")
    guard res else {
      print(formatError(
        at: path,
        row: structNode.range.startRow,
        column: structNode.range.startColumn,
        type: "warning",
        message: "Props is not Equatable"
      ))
      return res
    }
  }
  return res
}

private func walkParsedTree(_ path: String) throws -> TokenVisitor {
  let fileURL = URL(fileURLWithPath: path)
  let parsedTree = try SyntaxTreeParser.parse(fileURL)
  let visitor = TokenVisitor()
  parsedTree.walk(visitor)
  return visitor
}

private func formatError(
  at path: String,
  row: Int,
  column: Int,
  type: String,
  message: String
) -> String {
  return "\(path): \(row): \(column): \(type): \(message)"
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
