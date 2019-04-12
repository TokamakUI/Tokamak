//
//  Rule.swift
//  TokamakCLI
//
//  Created by Matvii Hodovaniuk on 4/9/19.
//

import Foundation
import SwiftSyntax

public protocol Rule {
  static var description: RuleDescription { get }
   static func validate(visitor: TokenVisitor) -> [StyleViolation]
}

extension Rule {
   public static func validate(path: String) throws -> [StyleViolation] {
        let fileURL = URL(fileURLWithPath: path)
        let parsedTree = try SyntaxTreeParser.parse(fileURL)
        let visitor = TokenVisitor()
        visitor.path = path
        parsedTree.walk(visitor)
        return validate(visitor: visitor)
    }
}
