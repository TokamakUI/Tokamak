//
//  Target.swift
//  Tokamak
//
//  Created by Max Desiatov on 10/02/2019.
//

open class Target {
  public internal(set) var node: AnyView

  public init<V: View>(node: V) {
    self.node = AnyView(node)
  }
}
