//
//  State.swift
//  Tokamak
//
//  Created by Max Desiatov on 09/02/2019.
//

typealias Updater<T> = (inout T) -> ()

/** Note that `set` functions are not `mutating`, they never update the
 component's state in-place synchronously, but only schedule an update with
 Tokamak at a later time. A call to `render` is only scheduled on the component
 that obtained this state with `hooks.state`.
 */
public struct State<T> {
  public let value: T

  /// A closure stored as `Handler` to enable `Equatable` implementation on
  /// `State` derived by the compiler.
  let updateHandler: Handler<Updater<T>>

  init(_ value: T, _ updater: @escaping (Updater<T>) -> ()) {
    self.value = value
    updateHandler = Handler(updater)
  }

  /// set the state to a specified value
  public func set(_ value: T) {
    updateHandler.value { $0 = value }
  }

  /// update the state with a pure function
  public func set(_ transformer: @escaping (T) -> T) {
    updateHandler.value { $0 = transformer($0) }
  }

  /// efficiently update the state in place with a mutating function
  /// (helps avoiding expensive memory allocations when state contains
  /// large arrays/dictionaries or other copy-on-write value)
  public func set(_ updater: @escaping (inout T) -> ()) {
    updateHandler.value(updater)
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

    let queueState = self.queueState
    return State(value) { (updater: Updater<T>) in
      queueState(index) {
        updater(&$0.assumingMemoryBound(to: T.self).pointee)
      }
    }
  }
}
