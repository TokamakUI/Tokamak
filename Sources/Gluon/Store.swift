//
//  Store.swift
//  Gluon
//
//  Created by Max Desiatov on 12/10/2018.
//

import Foundation

/// Generic undo-redo manager that doesn't require rollback implementation in
/// `apply` of a wrapped store. It saves previous snapshots of state in a stack
/// and undo/redo actions allow traversing the state history. This might be
/// not very efficient in terms of memory, but we also could require an initial
/// state and recreate subsequent snapshots by calling `apply` with a sequence
/// of actions
public struct History<S: Store>: Store {
  public enum Action {
    case branch(S.Action)
    case undo()
    case redo()
  }

  private var wrapped: S
  private var history = [S.State]()
  private var historyIndex: Int

  public var state: S.State {
    return history[historyIndex]
  }

  public mutating func apply(action: Action) {
    switch action {
    case let .branch(wrappedAction):
      wrapped.apply(action: wrappedAction)
      history.removeSubrange(historyIndex..<history.count)
      history.append(wrapped.state)
      historyIndex = history.count - 1
    case .undo:
      guard historyIndex > 0 else { return }

      historyIndex -= 1
    case .redo:
      guard historyIndex < history.count - 1 else { return }

      historyIndex += 1
    }
  }
}

public protocol Store {
  associatedtype State
  associatedtype Action

  var state: State { get }

  mutating func apply(action: Action)
}

// FIXME: need context working for its implementation
public final class StoreProvider<S>: Component<StoreProvider.Props, S>
where S: Store & StateType {
  struct Props: Equatable {
    /// FIXME: should store comparison be optimised this way?
    let store: Unique<S>
  }

  func dispatch(action: S.Action) {
    setState { $0.apply(action: action) }
  }

  public func render() -> Node {
    // FIXME: create a context here
    return Node(children)
  }
}

typealias Dispatch<Action> = (Action) -> ()
typealias Dispatcher<S: Store> = (state: S.State, dispatch: Dispatch<S.Action>)

// FIXME: when contexts are available read state and dispatch
// from the context and pass it to the mapper
func storeAccess<S: Store>(_ mapper: (Dispatcher<S>) -> Node) {

}
