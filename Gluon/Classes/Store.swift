//
//  Store.swift
//  Gluon
//
//  Created by Max Desiatov on 12/10/2018.
//

import Foundation

public protocol Store: Equatable {
  associatedtype State
  associatedtype Action

  func apply(action: Action, to: inout State)
}

// FIXME: need context working for its implementation
public final class StoreProvider<S>: Component<StoreProvider.Props, S.State>
where S: Store, S.State: StateType {
  struct Props: Equatable {
    var store: S
  }

  public func render() -> Node {
    return Node(children)
  }
}
