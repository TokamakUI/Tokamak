//
//  Helpers.swift
//  TokamakCLITests
//
//  Created by Matvii Hodovaniuk on 5/13/19.
//

import XCTest

struct UnexpectedNilError: Error {}

func srcRoot() throws -> String {
  guard let src = ProcessInfo.processInfo.environment["TEST_PATH"] else {
    throw UnexpectedNilError()
  }
  return src
}
