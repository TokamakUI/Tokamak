//
//  Hooks.swift
//  Tokamak
//
//  Created by Max Desiatov on 06/11/2018.
//

typealias Finalizer = (() -> ())?
typealias Effect = () -> Finalizer

protocol HookedComponent: AnyObject {
  /// State cells of this component indexed by order of `hooks.state` calls
  var state: [Any] { get set }

  /// Effect cells of this component indexed by order of `hooks.effect` calls
  var effects: [(observed: AnyEquatable?, Effect)] { get set }

  /// Finalizer cells of this component received from `Effect` evaluation.
  /// Indices in this array exactly match indices in `effects` array.
  var effectFinalizers: [Finalizer] { get set }

  /// Ref cells of this component indexed by order of `hooks.ref` calls
  var refs: [AnyObject] { get set }
}

/** Functions implemented directly in this class are parts of internal
 implementation of `Hooks`. The public API is defined in extensions of `Hooks`
 located in separate files in the same directory.
 */
public final class Hooks {
  /** Closure assigned by the reconciler before every `render` call. Queues
   a state update with this reconciler.
   */
  let queueState: (
    _ index: Int,
    _ updater: (inout Any) -> ()
  ) -> ()

  weak var component: HookedComponent?

  private var stateIndex = 0

  private var effectIndex = 0
  private(set) var scheduledEffects = Set<Int>()

  private var refIndex = 0

  init(
    component: HookedComponent,
    queueState: @escaping (
      _ index: Int,
      _ updater: (inout Any) -> ()
    ) -> ()
  ) {
    self.component = component
    self.queueState = queueState
  }

  /** For a given initial state return a current value of this state
   (initialized from `initial` if current was absent) and its index.
   */
  func currentState<T>(_ initial: T) -> (getter: () -> T, index: Int) {
    defer { stateIndex += 1 }

    guard let component = component else {
      fatalError("hooks.state should only be called within `render`")
    }

    if component.state.count <= stateIndex {
      component.state.append(initial)
    }

    let boundIndex = stateIndex
    // swiftlint:disable:next force_cast
    return ({ component.state[boundIndex] as! T }, stateIndex)
  }

  /** Schedules effect exection with the current reconciler accessed via
   `component`.
   */
  func scheduleEffect(
    _ observed: AnyEquatable?,
    _ effect: @escaping Effect
  ) {
    defer { effectIndex += 1 }

    guard let component = component else {
      assertionFailure("hooks.effect should only be called within `render`")
      return
    }

    if component.effects.count > effectIndex {
      guard component.effects[effectIndex].0 != observed else { return }

      component.effects[effectIndex].0 = observed
      component.effects[effectIndex].1 = effect
      scheduledEffects.insert(effectIndex)
    } else {
      component.effects.append((observed, effect))
      scheduledEffects.insert(effectIndex)
    }
  }
}
