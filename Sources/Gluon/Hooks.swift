//
//  Hooks.swift
//  Gluon
//
//  Created by Max Desiatov on 06/11/2018.
//

public protocol Navigator {
  func push(_ node: Node, animated: Bool)
  func pop(animated: Bool)
}

public protocol Presenter {
  func present(_ node: Node, animated: Bool)
  func dismiss(animated: Bool)
}

extension Navigator {
  public func push(_ node: Node) {
    push(node, animated: true)
  }

  public func pop() {
    pop(animated: true)
  }
}

extension Presenter {
  public func present(_ node: Node) {
    present(node, animated: true)
  }

  public func dismiss() {
    dismiss(animated: true)
  }
}

public struct Hooks {
  var currentState: ((_ id: String) -> Any?)?
  var queueState: ((_ state: Any, _ id: String) -> ())?
  public internal(set) var navigator: Navigator?
  public internal(set) var presenter: Presenter?

  /// This overload works around unexpected behaviour, where
  /// `"\(#file)\(#line)"` as a default arguments is evaluated to local values,
  /// not values at the call site.
  public func state<T>(_ initial: T,
                       file: String = #file,
                       line: Int = #line) -> (T, (T) -> ()) {
    return state(initial, id: "\(file)\(line)")
  }

  public func state<T>(_ initial: T,
                       id: String) -> (T, (T) -> ()) {
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
