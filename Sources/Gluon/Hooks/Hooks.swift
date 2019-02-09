//
//  Hooks.swift
//  Gluon
//
//  Created by Max Desiatov on 06/11/2018.
//

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

  public func ref<T>(_ initial: T? = nil) -> Ref<T> {
    // FIXME: return an existing ref if there is one available in reconciler
    return Ref(initial)
  }
}
