//
//  RuleDescription.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 4/9/19.
//

public struct RuleDescription: Equatable {
  public let identifier: String
  public let name: String
  public let description: String

  public init(identifier: String, name: String, description: String) {
    self.identifier = identifier
    self.name = name
    self.description = description
  }

  // MARK: Equatable

  public static func ==(lhs: RuleDescription, rhs: RuleDescription) -> Bool {
    return lhs.identifier == rhs.identifier
  }
}
