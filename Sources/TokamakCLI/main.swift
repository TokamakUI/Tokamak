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
  let logFilePath = Key<String>("-l", "--log-file", description: "The log file location")

  func execute() throws {
    var logHandler = try TokamakLogger(
      label: "TokamakCLI Output",
      path: logFilePath.value
    )
    if logFilePath.value != nil {
      logHandler.outputs.append(.file)
    }
    if path.value.contains(".swift") {
      do {
        try lintFile("\(path.value)", logHandler: logHandler)
      } catch {
        logHandler.log(
          message: "Can't lint file"
        )
        logHandler.log(
          message: "\(error)"
        )
      }
    } else {
      do {
        try lintFolder("\(path.value)", logHandler: logHandler)
      } catch {
        logHandler.log(
          message: "Can't lint folder"
        )
        logHandler.log(
          message: "\(error)"
        )
      }
    }
  }
}

let tokamakCLI = CLI(name: "TokamakCLI", version: "0.1.2", description: "Tokamak CLI tools")

tokamakCLI.commands = [LintCommand()]
tokamakCLI.goAndExit()
