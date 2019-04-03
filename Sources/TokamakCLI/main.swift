//
//  main.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 3/29/19.
//

import Foundation
import TokamakLint

public final class CommandLineTool {
  private let lint: TokamakLint

  public init() {
    let lint = TokamakLint()
    self.lint = lint
    print(lint.isPropsEquatable("/Users/hmi/Documents/maxDesiatov/Tokamak/Tests/TokamakCLITests/TestPropsEquatable.swift"))
    print("/Users/hmi/Documents/maxDesiatov/Tokamak/Example/Tokamak/Components/Constraints.swift:1:2: warning: Line Length Violation: Violation Reason. (line_length)")
  }
}

let tool = CommandLineTool()
