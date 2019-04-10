//
//  Rule.swift
//  TokamakCLI
//
//  Created by Matvii Hodovaniuk on 4/9/19.
//

import Foundation

public protocol Rule {
  static var description: RuleDescription { get }

  init()

  static func validate(path: String) throws -> [StyleViolation]
  static func validate(visitor: TokenVisitor) -> [StyleViolation]
}

extension Rule {
  public func isEqualTo(_ rule: Rule) -> Bool {
    return type(of: self).description == type(of: rule).description
  }
}
