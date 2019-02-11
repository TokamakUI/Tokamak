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

  /// set the state to a specified value
  public func set(_ value: T) {
    setter.value(value)
  }

  /// update the state with a pure function
  public func set(_ updater: (T) -> T) {
    setter.value(updater(value))
  }
}

extension State: Equatable where T: Equatable {}

extension Hooks {
  /** Allows a component to have its own state and to be updated when the state
   changes. Returns a very simple state container, which on initial call of
   render contains `initial` as a value and values passed to `count.set`
   on subsequent updates:
   */
  public func state<T>(_ initial: T) -> State<T> {
    let (value, index) = currentState(initial)

    return State(value as? T ?? initial) { [weak self] in
      self?.queueState($0, index)
    }
  }
}
