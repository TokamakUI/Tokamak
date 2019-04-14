//
//  ViolationSeverity.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 4/9/19.
//

public enum ViolationSeverity: String, Comparable {
  case warning
  case error

  // MARK: Comparable

  public static func <(lhs: ViolationSeverity, rhs: ViolationSeverity) -> Bool {
    return lhs == .warning && rhs == .error
  }
}
