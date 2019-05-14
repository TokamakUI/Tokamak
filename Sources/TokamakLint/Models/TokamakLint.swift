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
                  print("Error while reading a list of files in folder at \(url.path): ", error)
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
          "(\(i + 1)/\(count))")
    let errors = try checkFile(fileURL.path)
    if errors.count > 0 {
      print(XcodeReporter.generateReport(errors))
    }
  }
}

public func lintFile(_ path: String) throws {
  print("Linting \(path)")
  let errors = try checkFile(path)
  if errors.count > 0 {
    print(XcodeReporter.generateReport(errors))
  }
}

func checkFile(_ path: String) throws -> [StyleViolation] {
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
  let visitor = TokenVisitor(path: path)
  parsedTree.walk(visitor)
  return visitor
}

private func isSwiftFile(_ path: String) -> Bool {
  return path.contains(".swift")
}

private func hasTokamakImport(from visitor: TokenVisitor) -> Bool {
  return visitor.root.children(with: SyntaxKind.importDecl.rawValue)
    .flatMap { $0.children(with: SyntaxKind.accessPathComponent.rawValue) }
    .compactMap { $0.children.first }
    .contains { $0.text == "Tokamak" }
}
