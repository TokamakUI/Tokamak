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
    // create url to test file
    guard let url = fm.urls(
      for: FileManager.SearchPathDirectory.documentDirectory,
      in: FileManager.SearchPathDomainMask.userDomainMask
    )
    .last?.appendingPathComponent("test_log.txt")
    else { return }

    // clear file
    let text = ""
    try text.write(toFile: url.path, atomically: false, encoding: .utf8)

    let firstMessage: Logger.Message = "Information message"
    let secondMessage: Logger.Message = "Warning message"
    let allMessages = "\(firstMessage)\(secondMessage)"

    var logHandler = try TokamakLogger(label: "TokamakCLI Output", path: url.path)
    logHandler.logLevel = .warning
    logHandler.outputs = [.stdout, .file]

    logHandler.log(message: firstMessage)

    XCTAssertEqual(
      String(
        try String(contentsOf: url, encoding: .utf8)
          .filter { !"\n".contains($0) }
      ),
      String(firstMessage.description)
    )

    logHandler.log(message: secondMessage)

    XCTAssertEqual(
      String(
        try String(contentsOf: url, encoding: .utf8)
          .filter { !"\n".contains($0) }
      ),
      String(allMessages.description)
    )
  }
}
