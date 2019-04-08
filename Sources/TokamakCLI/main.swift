//
//  main.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 3/29/19.
//

import Foundation
import TokamakLint

do {
  try lintFolder(CommandLine.arguments.first
    ?? FileManager.default.currentDirectoryPath)
} catch let error {
    print("Can't lint folder")
    print(error)
}
