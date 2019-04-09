//
//  Rule.swift
//  TokamakCLI
//
//  Created by Matvii Hodovaniuk on 4/9/19.
//

import Foundation

public protocol Rule {
    static var description: RuleDescription { get }
    var configurationDescription: String { get }

    init() // Rules need to be able to be initialized with default values
    init(configuration: Any) throws

    func validate(file: File, compilerArguments: [String]) -> [StyleViolation]
    func validate(file: File) -> [StyleViolation]
}

extension Rule {
    public func isEqualTo(_ rule: Rule) -> Bool {
        return type(of: self).description == type(of: rule).description
    }
}

