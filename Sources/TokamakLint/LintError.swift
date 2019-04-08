//
//  LintError.swift
//  TokamakCLI
//
//  Created by Matvii Hodovaniuk on 4/8/19.
//

import Foundation

public enum LintError: Error, CustomStringConvertible {
  case hasntTokamakImport
  case propsIsNotEquatable

  public var description: String {
    switch self {
    case .hasntTokamakImport:
      return "Hasn't Tokamak import"
    case .propsIsNotEquatable:
      return "Props is not Equatable"
    }
  }
}
