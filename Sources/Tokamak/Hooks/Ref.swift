//
//  Ref.swift
//  Tokamak
//
//  Created by Max Desiatov on 09/02/2019.
//

public final class Ref<T> {
  public var value: T

  init(_ value: T) {
    self.value = value
  }
}

extension Hooks {
  public func ref<T>(type: T.Type) -> Ref<T?> {
    return ref(Ref(nil))
  }

  public func ref<T>(_ initial: T) -> Ref<T> {
    return ref(Ref(initial))
  }
}
