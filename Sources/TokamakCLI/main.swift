//
//  main.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 3/29/19.
//

import Foundation
// import SwiftSyntax
import TokamakLint

public final class CommandLineTool {
  private let arguments: [String]
  private let lint: TokamakLint

  public init() {
    let lint = TokamakLint()
    self.lint = lint
    arguments = ["a", "b"]
  }
}
