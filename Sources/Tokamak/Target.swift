//
//  Target.swift
//  Tokamak
//
//  Created by Max Desiatov on 10/02/2019.
//

open class Target {
  public internal(set) var view: AnyView

  public init<V: View>(_ view: V) {
    self.view = AnyView(view)
  }
}
