//
//  Context.swift
//  Tokamak
//
//  Created by Max Desiatov on 22/02/2019.
//

protocol AnyContext {}

protocol Context: AnyContext, Equatable, Default where DefaultValue == Self {}

extension Context {
  static func node(_ value: Self) -> AnyNode {
    return AnyNode(
      ref: nil,
      props: AnyEquatable(value),
      children: AnyEquatable(Null()),
      type: .context(Self.self)
    )
  }
}

extension Hooks {
  func context<C: Context>(_ type: C.Type) -> C {
    return C.defaultValue
  }
}
