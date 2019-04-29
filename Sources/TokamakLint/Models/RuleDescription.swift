//
//  RuleDescription.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 4/9/19.
//

struct RuleDescription: Equatable {
  public let identifier: String
  public let name: String
  public let description: String

  init(type: Rule.Type, name: String, description: String) {
    identifier = String(describing: type)
    self.name = name
    self.description = description
  }

  // MARK: Equatable

  public static func ==(lhs: RuleDescription, rhs: RuleDescription) -> Bool {
    return lhs.identifier == rhs.identifier
  }
}
