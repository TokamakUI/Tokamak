//
//  StyleViolation.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 4/9/19.
//

struct StyleViolation: CustomStringConvertible, Equatable {
  public let ruleDescription: RuleDescription
  public let location: Location
  public let reason: String
  public var description: String {
    return XcodeReporter.generateForSingleViolation(self)
  }

  init(ruleDescription: RuleDescription, severity: ViolationSeverity = .warning,
       location: Location, reason: String? = nil) {
    self.ruleDescription = ruleDescription
    self.location = location
    self.reason = reason ?? ruleDescription.description
  }
}
