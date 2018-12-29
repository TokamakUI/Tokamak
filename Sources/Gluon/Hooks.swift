//
//  Hooks.swift
//  Gluon
//
//  Created by Max Desiatov on 06/11/2018.
//

public struct Hooks {
  var currentState: ((_ id: String) -> Any?)?
  var queueState: ((_ state: Any, _ id: String) -> ())?

  public func state<T>(_ initial: T,
                       id: String = "\(#file)\(#line)") -> (T, (T) -> ()) {
    guard let currentState = currentState,
      let queueState = queueState else {
      fatalError("""
        attempt to use `state` hook outside of a `render` function,
        or `render` is not called from a renderer
      """)
    }

    let current = currentState(id) as? T ?? initial

    return (current, { queueState($0, id) })
  }
}
