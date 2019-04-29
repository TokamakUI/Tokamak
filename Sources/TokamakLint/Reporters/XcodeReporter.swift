//
//  XcodeReporter.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 4/9/19.
//

struct XcodeReporter: Reporter {
  public static let identifier = "xcode"
  public static let isRealtime = true

  public var description: String {
    return "Reports violations in the format Xcode uses to display in the IDE. (default)"
  }

  public static func generateReport(_ violations: [StyleViolation]) -> String {
    return violations.map(generateForSingleViolation).joined(separator: "\n")
  }

  static func generateForSingleViolation(_ violation: StyleViolation) -> String {
    // {full_path_to_file}{:line}{:character}: {error,warning}: {content}
    return [
      "\(violation.location): ",
      "\(violation.ruleDescription.name) Violation: ",
      violation.reason,
      " (\(violation.ruleDescription.identifier))",
    ].joined()
  }
}
