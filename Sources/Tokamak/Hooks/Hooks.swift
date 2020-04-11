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
}
