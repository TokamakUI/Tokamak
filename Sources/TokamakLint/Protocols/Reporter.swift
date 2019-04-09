//
//  Reporter.swift
//  TokamakLint
//
//  Created by Matvii Hodovaniuk on 4/9/19.
//

public protocol Reporter: CustomStringConvertible {
    static var identifier: String { get }
    static var isRealtime: Bool { get }

    static func generateReport(_ violations: [StyleViolation]) -> String
}

public func reporterFrom(identifier: String) -> Reporter.Type {
    switch identifier {
    case XcodeReporter.identifier:
        return XcodeReporter.self
    default:
        queuedFatalError("no reporter with identifier '\(identifier)' available.")
    }
}

