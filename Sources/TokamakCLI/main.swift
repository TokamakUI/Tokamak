//
//  main.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 3/29/19.
//

import Foundation
import SwiftCLI
import TokamakLint

class LintCommand: Command {
  let name = "lint"
  let shortDescription = "Lint folder or file"
  let path = Parameter()

  func execute() throws {
    do {
      let srcRoot = ProcessInfo.processInfo.environment["SRCROOT"]!
      if path.value.contains(".swift") {
        try lintFile("\(srcRoot)/\(path.value)")
      } else {
        try lintFolder("\(srcRoot)/\(path.value)")
      }
    } catch {
      print("Can't lint folder")
      print(error)
    }
  }
}

let TokamakCLI = CLI(name: "TokamakCLI", version: "0.1.2", description: "Tokamka CLI tools")

TokamakCLI.commands = [LintCommand()]
TokamakCLI.go()
