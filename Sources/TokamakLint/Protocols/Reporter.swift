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
