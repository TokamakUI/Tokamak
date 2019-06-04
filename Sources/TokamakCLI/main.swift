//
//  main.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 3/29/19.
//

import Foundation
import Logging
import SwiftCLI
import TokamakLint

class LintCommand: Command {
  let name = "lint"
  let shortDescription = "Lint folder or file"
  let path = Parameter()
  let logFilePath = Key<String>("-l", "--log-file", description: "The log file location")

  func execute() throws {
    // setup logger
    LoggingSystem.bootstrap {
      var tokamakLogHandler = TokamakLogHandler(label: $0)
      do {
        try tokamakLogHandler.setup(path: self.logFilePath.value)
      } catch {
        print(error)
      }
      return tokamakLogHandler
    }
    let logger = Logger(label: "TokamakCLI Output")

    if path.value.contains(".swift") {
      do {
        try lintFile("\(path.value)", logger: logger)
      } catch {
        logger.info("Can't lint file")
        logger.info("\(error)")
      }
    } else {
      do {
        try lintFolder("\(path.value)", logger: logger)
      } catch {
        logger.info("Can't lint folder")
        logger.info("\(error)")
      }
    }
  }
}

let tokamakCLI = CLI(name: "TokamakCLI", version: "0.1.2", description: "Tokamak CLI tools")

tokamakCLI.commands = [LintCommand()]
tokamakCLI.goAndExit()
