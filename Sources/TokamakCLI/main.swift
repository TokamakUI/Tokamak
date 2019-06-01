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
    if path.value.contains(".swift") {
      do {
        try lintFile("\(path.value)")
      } catch {
        print("Can't lint file")
        print(error)
      }
    } else {
      do {
        try lintFolder("\(path.value)")
      } catch {
        print("Can't lint folder")
        print(error)
      }
    }
  }
}

let tokamakCLI = CLI(name: "TokamakCLI", version: "0.1.2", description: "Tokamak CLI tools")

tokamakCLI.commands = [LintCommand()]
tokamakCLI.goAndExit()
