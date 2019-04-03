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
    do {
      let fileURL: URL = URL(fileURLWithPath: path)
//      let fileSource = try String(contentsOf: fileURL, encoding: .utf8)

      let parsedTree = try SyntaxTreeParser.parse(fileURL)
      let visitor = TokenVisitor()
      parsedTree.walk(visitor)
      let structs = visitor.getNodes(get: "StructDecl", from: visitor.tree[0])
      for structNode in structs {
//            visitor.getNodes(get: , from: structNode)
        let isInherited = visitor.isInherited(node: structNode, from: "Equatable")
        print(isInherited)
      }
    } catch {
      print(error)
    }
  }

  public func isPropsEquatable(_ path: String) -> Bool {
    var res: Bool = false
    do {
      let fileURL: URL = URL(fileURLWithPath: path)
      let parsedTree = try SyntaxTreeParser.parse(fileURL)
      let visitor = TokenVisitor()
      parsedTree.walk(visitor)
      let structs = visitor.getNodes(get: "StructDecl", from: visitor.tree[0])
      for structNode in structs {
        if structNode.children[1].text == "Props" {
          res = visitor.isInherited(node: structNode, from: "Equatable")
        }
      }
    } catch {
      print(error)
      return false
    }
    return res
  }

  public func isSwiftFile(_ path: String) -> Bool {
    return path.contains(".swift")
  }

  public func hasTokamakImport(_ code: String) -> Bool {
    return code.contains("import Tokamak")
  }
}
