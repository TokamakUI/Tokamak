//
//  LoggerTest.swift
//  TokamakCLITests
//
//  Created by Matvii Hodovaniuk on 5/31/19.
//

import Logging
@testable import TokamakLint
import XCTest

final class LoggerTests: XCTestCase {
  func testLogger() throws {
    var logHandler = TokamakLogger(label: "TokamakCLI Output")
    logHandler.outputs = [.stdout, .file]
    logHandler.log(level: .warning, message: "Msg")
  }
}
