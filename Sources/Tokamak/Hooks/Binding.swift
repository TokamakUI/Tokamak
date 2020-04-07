//
//  Binding.swift
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
@propertyWrapper public struct Binding<Value> {
  public var wrappedValue: Value {
    get { get() }
    nonmutating set { set(newValue) }
  }

  private let get: () -> Value
  private let set: (Value) -> ()

  public var projectedValue: Binding<Value> { self }

  init(get: @escaping () -> Value, set: @escaping (Value) -> ()) {
    self.get = get
    self.set = set
  }

  public subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Value, Subject>) -> Binding<Subject> {
    .init(get: {
      self.wrappedValue[keyPath: keyPath]
    }, set: {
      self.wrappedValue[keyPath: keyPath] = $0
        })
  }
}

// FIXME: absent in the reference interface
extension Binding: Equatable where Value: Equatable {
  public static func ==(lhs: Binding<Value>, rhs: Binding<Value>) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension Hooks {
  /** Allows a component to have its own state and to be updated when the state
   changes. Returns a very simple state container, which on initial call of
   render contains `initial` as a value and values passed to `count.set`
   on subsequent updates:
   */
  public func state<T>(_ initial: T) -> Binding<T> {
    let (get, index) = currentState(initial)

    let queueState = self.queueState
    return Binding(get: get, set: { newValue in
      queueState(index) {
        $0 = newValue
      }
    })
  }
}
