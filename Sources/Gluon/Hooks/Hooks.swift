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
  /** Closure assigned by the reconciler before every `render` call. Queues
   a state update with this reconciler.
   */
  let queueState: (_ newState: Any, _ index: Int) -> ()

  private weak var component: HookedComponent?
  private var stateIndex = 0

  init(
    component: HookedComponent,
    queueState: @escaping (_ value: Any, _ index: Int) -> ()
  ) {
    self.component = component
    self.queueState = queueState
  }

  /** For a given initial state it returns a current value of this state
   (initialized from `initial` if current was absent) and its index.
   */
  func currentState(_ initial: Any) -> (current: Any, index: Int) {
    defer { stateIndex += 1 }

    guard let component = component else { return (initial, stateIndex) }

    if component.state.count > stateIndex {
      return (component.state[stateIndex], stateIndex)
    } else {
      component.state.append(initial)
      return (initial, stateIndex)
    }
  }

  /** Closure assigned by the reconciler before every `render` call. Schedules
   effect exection with this reconciler.
   */
  var scheduleEffect: ((
    _ observed: AnyEquatable?,
    _ effect: @escaping Effect
  ) -> ())?

  var ref: ((_ initial: Any) -> AnyRef)?
}
