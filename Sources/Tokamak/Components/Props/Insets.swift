//
//  Insets.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 17/01/2019.
//

public struct Insets: Equatable {
  public let top: Double
  public let bottom: Double
  public let left: Double
  public let right: Double

  public init(top: Double, bottom: Double, left: Double, right: Double) {
    self.top = top
    self.bottom = bottom
    self.left = left
    self.right = right
  }

  public static var zero: Insets {
    return .init(top: 0, bottom: 0, left: 0, right: 0)
  }
}
