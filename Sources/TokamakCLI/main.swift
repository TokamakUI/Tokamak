//
//  main.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 3/29/19.
//

import Foundation
import TokamakLint

public final class CommandLineTool {
  public let path: String

  public init(arguments: [String] = CommandLine.arguments) {
    if let path = arguments.first {
      self.path = path
    } else {
      let fileManager = FileManager.default
      path = fileManager.currentDirectoryPath
    }
  }
}

let tool = CommandLineTool()
try lintFolder(CommandLine.arguments.first ?? FileManager.default.currentDirectoryPath)
