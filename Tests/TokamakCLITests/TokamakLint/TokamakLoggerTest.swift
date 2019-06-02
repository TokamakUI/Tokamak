//
//  LoggerTest.swift
//  TokamakCLITests
//
//  Created by Matvii Hodovaniuk on 5/31/19.
//

import Logging
@testable import TokamakLint
import XCTest

final class TokamakLoggerTests: XCTestCase {
  func testLogToFile() throws {
    let fm = FileManager.default
    guard let url = fm.urls(
      for: FileManager.SearchPathDirectory.desktopDirectory,
      in: FileManager.SearchPathDomainMask.userDomainMask
    )
    .last?.appendingPathComponent("log.txt")
    else { return }

    var logHandler = TokamakLogger(label: "TokamakCLI Output")
    logHandler.logLevel = .warning
    logHandler.outputs = [.stdout, .file]
    logHandler.path = url
    logHandler.log(level: .warning, message: "Msg")
  }
}
