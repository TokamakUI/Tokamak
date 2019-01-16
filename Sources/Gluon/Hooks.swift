//
//  Hooks.swift
//  Gluon
//
//  Created by Max Desiatov on 06/11/2018.
//

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

public struct Hooks {
  var currentState: ((Any) -> (Any, Int))?
  var queueState: ((_ state: Any, _ index: Int) -> ())?

  public func state<T>(_ initial: T) -> State<T> {
    guard let currentState = currentState,
      let queueState = queueState else {
      fatalError("""
        attempt to use `state` hook outside of a `render` function,
        or `render` is not called from a renderer
      """)
    }

    let (value, index) = currentState(initial)

    return State(value as? T ?? initial) { queueState($0, index) }
  }
}
