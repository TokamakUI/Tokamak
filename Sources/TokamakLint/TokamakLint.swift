//
//  TokamakLint.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 4/1/19.
//

import Foundation
import SwiftSyntax

public final class TokamakLint {
  private let arguments: [String]

  public init() {
    arguments = ["a", "b"]
  }

  public func lintFolder(_ path: String) {
    do {
      let resourceKeys: [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
      let baseurl: URL = URL(fileURLWithPath: path)
      let enumerator = FileManager
        .default
        .enumerator(at: baseurl,
                    includingPropertiesForKeys: resourceKeys,
                    options: [.skipsHiddenFiles],
                    errorHandler: { (url, error) -> Bool in
                      print("directoryEnumerator error at \(url): ", error)
                      return true
        })!

      for case let fileURL as URL in enumerator {
        if isSwiftFile(fileURL.path) {
          let fileSource = try String(contentsOf: fileURL, encoding: .utf8)

          print(fileSource)
          if hasTokamakImport(fileSource) {
            let parsedTree = try SyntaxTreeParser.parse(fileURL)
            let visitor = TokenVisitor()
            parsedTree.walk(visitor)
          }
        }
      }
    } catch {
      print(error)
    }
  }

  public func lintFile(_ path: String) {
    let rightStruct = """
    struct Props: Equatable {
        str: String
    }
"""
    SwiftSyntax.Parser
    SyntaxParser.parse(rightStruct)
//    do {
//      let fileURL: URL = URL(fileURLWithPath: path)
////      let fileSource = try String(contentsOf: fileURL, encoding: .utf8)
////      if hasTokamakImport(fileSource) {
        let parsedTree = try SyntaxTreeParser.parse(fileURL)
//        let visitor = TokenVisitor()
//        parsedTree.walk(visitor)
////        find "StructDecl"
////        check children[1] is searchable Name of struct
////        then find "TypeInheritanceClause"
////        and concat children
////        look for search type
//        visitor.isHasType(check: visitor.tree[0], for: "Equatable")
////      }
//    } catch {
//      print(error)
//    }
  }

  public func isSwiftFile(_ path: String) -> Bool {
    return path.contains(".swift")
  }

    

  public func hasTokamakImport(_ code: String) -> Bool {
    return code.contains("import Tokamak")
  }
}
