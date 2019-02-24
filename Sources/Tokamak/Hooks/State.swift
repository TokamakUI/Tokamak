//
//  State.swift
//  Tokamak
//
//  Created by Max Desiatov on 09/02/2019.
//

/// Formalizes an update to a value with a given action. Note that `update`
/// function is mutating here to allow efficient in-place updates. As long as
/// `Updatable` is implemented on a value type, this still allows freezing it
/// into an immutable value when needed.
public protocol Updatable {
  associatedtype Action

  mutating func update(_ action: Action)
}

typealias Updater<T> = (inout T) -> ()

/** Note that `set` functions are not `mutating`, they never update the
 component's state in-place synchronously, but only schedule an update with
 Tokamak at a later time. A call to `render` is only scheduled on the component
 that obtained this state with `hooks.state`.
 */
public final class State<T> {
  public var value: T {
    return getter()
  }

  var version = UniqueReference()

  let getter: () -> T
  let updateHandler: (Updater<T>) -> ()

  init(
    _ getter: @escaping () -> T,
    _ updateHandler: @escaping (Updater<T>) -> ()
  ) {
    self.getter = getter
    self.updateHandler = updateHandler
  }

  /// set the state to a specified value
  public func set(_ value: T) {
    version = UniqueReference()
    updateHandler { $0 = value }
  }

  /// update the state with a pure function
  public func set(_ transformer: @escaping (T) -> T) {
    version = UniqueReference()
    updateHandler { $0 = transformer($0) }
  }

  /// efficiently update the state in place with a mutating function
  /// (helps avoiding expensive memory allocations when state contains
  /// large arrays/dictionaries or other copy-on-write value)
  public func set(_ updater: @escaping (inout T) -> ()) {
    version = UniqueReference()
    updateHandler(updater)
  }
}

extension State where T: Updatable {
  /// For any `Updatable` state you can dispatch an `Action` to reduce that
  /// state to a different value.
  public func set(_ action: T.Action) {
    version = UniqueReference()
    updateHandler { $0.update(action) }
  }
}

extension State: Equatable {
  public static func ==(lhs: State<T>, rhs: State<T>) -> Bool {
    return lhs.version == rhs.version
  }
}

extension Hooks {
  /** Allows a component to have its own state and to be updated when the state
   changes. Returns a state container, which on initial call to component's
   `render` contains `initial` as a value and values passed to `State.set`
   on subsequent updates:
   */
  public func state<T>(_ initial: T) -> State<T> {
    let (value, index) = currentState(initial)

    let queueState = self.queueState
    return State({ value as? T ?? initial }) { (updater: Updater<T>) in
      queueState(index) {
        // There's no easy way to downcast elements of `[Any]` to `T`
        // and apply `inout` updater without creating copies, working around
        // that with pointers.
        withUnsafeMutablePointer(to: &$0) {
          $0.withMemoryRebound(to: T.self, capacity: 1) { updater(&$0[0]) }
        }
      }
    }
  }
}
