//
//  Unique.swift
//  Gluon
//
//  Created by Max Desiatov on 06/11/2018.
//

import Foundation

public struct Unique<T>: Equatable {
  private let uuid = UUID()
  let boxed: T

  public init(_ boxed: T) {
    self.boxed = boxed
  }

  public static func == (lhs: Unique<T>, rhs: Unique<T>) -> Bool {
    return lhs.uuid == rhs.uuid
  }
}
