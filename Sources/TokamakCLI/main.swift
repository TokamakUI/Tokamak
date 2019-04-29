//
//  main.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 3/29/19.
//

import Foundation
import TokamakLint

do {
  let srcRoot = ProcessInfo.processInfo.environment["SRCROOT"]!
  try lintFolder("\(srcRoot)/Sources/Tokamak/Components/Host")
} catch {
  print("Can't lint folder")
  print(error)
}
