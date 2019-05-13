//
//  Location.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 4/9/19.
//

import Foundation
import SwiftSyntax

public struct Location: CustomStringConvertible, Comparable {
  public let file: String
  public let line: Int
  public let character: Int
  public var description: String {
    // Xcode likes warnings and errors in the following format:
    // {full_path_to_file}{:line}{:character}: {error, warning}: {content}
    return "\(file):\(line):\(character)"
  }

  public init(file: String, line: Int, character: Int) {
    self.file = file
    self.line = line
    self.character = character
  }

  // MARK: Comparable

  public static func <(lhs: Location, rhs: Location) -> Bool {
    if lhs.file != rhs.file {
      return lhs.file < rhs.file
    }
    if lhs.line != rhs.line {
      return lhs.line < rhs.line
    }
    return lhs.character < rhs.character
  }
}
