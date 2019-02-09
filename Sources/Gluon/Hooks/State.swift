//
//  State.swift
//  Gluon
//
//  Created by Max Desiatov on 09/02/2019.
//

/** Note that `set` functions are not `mutating`, they never update the
 component's state in-place synchronously, but only schedule an update with
 Gluon at a later time. A call to `render` is only scheduled on the component
 that obtained this state with `hooks.state`.
 */
public struct State<T> {
  public let value: T
  let setter: Handler<T>

  init(_ value: T, _ setter: @escaping (T) -> ()) {
    self.value = value
    self.setter = Handler(setter)
  }

  public func set(_ value: T) {
    setter.value(value)
  }

  public func set(_ updater: (T) -> T) {
    setter.value(updater(value))
  }
}

extension State: Equatable where T: Equatable {}
