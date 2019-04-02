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
      let fileSource = try String(contentsOf: fileURL, encoding: .utf8)

      print(fileSource)
//      if hasTokamakImport(fileSource) {
        let parsedTree = try SyntaxTreeParser.parse(fileURL)
        let visitor = TokenVisitor()
        parsedTree.walk(visitor)
        print(visitor)
//      }
    } catch {
      print(error)
    }
  }

  public func isSwiftFile(_ path: String) -> Bool {
    return path.contains(".swift")
  }

  public func hasTokamakImport(_ code: String) -> Bool {
    return code.contains("import Tokamak")
  }
}
