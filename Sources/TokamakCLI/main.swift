//
//  main.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 3/29/19.
//

import Foundation
import TokamakLint

public final class CommandLineTool {
  public let lint: TokamakLint
    public let path: String

    public init(arguments: [String] = CommandLine.arguments) {
        let lint = TokamakLint()

        if arguments.indices.contains(1) {
            self.path = arguments[1]
        } else {
            let fileManager = FileManager.default
            let currentDirectoryPath = fileManager.currentDirectoryPath
            self.path = currentDirectoryPath
        }
        self.lint = lint
    }
}

let tool = CommandLineTool()
tool.lint.lintFolder(tool.path)
