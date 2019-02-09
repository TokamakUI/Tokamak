//
//  Ref.swift
//  Gluon
//
//  Created by Max Desiatov on 09/02/2019.
//

public final class Ref<T> {
  public var value: T?

  init(_ value: T?) {
    self.value = value
  }
}
