//
//  LintError.swift
//  TokamakCLI
//
//  Created by Matvii Hodovaniuk on 4/8/19.
//

import Foundation

public enum LintError: Error, CustomStringConvertible {
  case propsIsNotEquatable

  public var description: String {
    switch self {
    case .propsIsNotEquatable:
      return
        """
        Props is not Equatable:\
        add conformance to Equatable protocol to your Props type
        """
    }
  }
}
