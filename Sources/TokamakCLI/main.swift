//
//  main.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 3/29/19.
//

import Foundation
import TokamakLint

do {
  let errors = try lintFolder(CommandLine.arguments.first
    ?? FileManager.default.currentDirectoryPath)
  if errors.count > 0 {
    XcodeReporter.generateReport(errors)
  } else {
    print("Folder clean")
  }
} catch {
  print("Can't lint folder")
  print(error)
}
