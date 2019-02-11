//
//  Hooks.swift
//  Gluon
//
//  Created by Max Desiatov on 06/11/2018.
//

typealias Finalizer = (() -> ())?
typealias Effect = () -> Finalizer

protocol HookedComponent: class {
  /// State cells of this component indexed by order of `hooks.state` calls
  var state: [Any] { get set }

  /// Effect cells of this component indexed by order of `hooks.effect` calls
  var effects: [(observed: AnyEquatable?, Effect)] { get set }

  /// Finalizer cells of this component received from `Effect` evaluation.
  /// Indices in this array exactly match indices in `effects` array.
  var effectFinalizers: [Finalizer] { get set }
}

/** Functions implemented directly in this class are parts of internal
 implementation of `Hooks`. The public API is defined in extensions of `Hooks`
 located in separate files in the same directory.
 */
public final class Hooks {
  weak var component: HookedComponent?

  init(
    component: HookedComponent,
    queueState: @escaping (_ value: Any, _ id: Int) -> ()
  ) {
    self.component = component
  }

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
