//
//  Hooks.swift
//  Gluon
//
//  Created by Max Desiatov on 06/11/2018.
//

typealias Effect = () -> (() -> ())?

public struct Hooks {
  /** Closure assigned by the reconciler before every `render` call. For a
   given initial state it returns a current value of this state (initialized
   from `initial` if current was absent) and its index.
   */
  var currentState: ((_ initial: Any) -> (current: Any, index: Int))?

  /** Closure assigned by the reconciler before every `render` call. Queues
   a state update with this reconciler.
   */
  var queueState: ((_ newState: Any, _ index: Int) -> ())?

  /** Closure assigned by the reconciler before every `render` call. Schedules
   effect exection with this reconciler.
   */
  var scheduleEffect: ((
    _ observed: AnyEquatable?,
    _ effect: @escaping Effect
  ) -> ())?

  var ref: ((_ initial: Any) -> AnyRef)?
}
