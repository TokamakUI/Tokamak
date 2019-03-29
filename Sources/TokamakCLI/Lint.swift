//
//  Lint.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 3/29/19.
//

import Foundation
import SwiftSyntax

public struct XcodeReporter: CustomStringConvertible {
    public static let identifier = "xcode"
    public static let isRealtime = true

    public static func generateReport(_ path: String) -> String {
        return "\(path):1:2: warning: Line Length Violation: Violation Reason. (line_length)"
    }
}

public final class CommandLineTool {
    private let arguments: [String]

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    public func run() throws {
        let file = CommandLine.arguments[1]
        let url = URL(fileURLWithPath: file)
        print(XcodeReporter.generateReport(file))
    }
}
