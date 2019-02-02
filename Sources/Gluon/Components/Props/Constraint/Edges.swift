//
//  Edges.swift
//  Gluon
//
//  Created by Max Desiatov on 02/02/2019.
//

public struct Edges: Equatable {
  public let target: Constraint.Target
  public let insets: Insets

  public static func equal(
    to target: Constraint.Target,
    insets: Insets = .zero
  ) -> Constraint {
    return .edges(Edges(target: target, insets: insets))
  }
}
