//
//  main.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 3/29/19.
//

import Foundation
import TokamakLint

do {
  let srcRoot = FileManager.default.currentDirectoryPath
  let errors = try lintFile("\(srcRoot)/Sources/Tokamak/Components/Host/Alert.swift")
  if errors.count > 0 {
    print(XcodeReporter.generateReport(errors))
  } else {
    print("Folder clean")
  }
} catch {
  print("Can't lint folder")
  print(error)
}
