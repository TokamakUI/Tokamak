//
//  StackReconciler.swift
//  Gluon
//
//  Created by Max Desiatov on 28/11/2018.
//

private let _hooks = Hooks()

extension Component {
  public static var hooks: Hooks {
    return _hooks
  }
}

public struct Hooks {
  public func state<T>(_ initial: T,
                       id: Int = #line) -> (T, (T) -> ()) {
    return (initial, { _ in })
  }
}

struct Pair<T: Hashable, U: Hashable>: Hashable {
  let first: T
  let second: U
}

final class NodeReference {
  let key: String?
  let props: AnyEquatable
  let children: AnyEquatable
  let type: _Component.Type

  init(node: Node) {
    self.key = node.key
    self.props = node.props
    self.children = node.children
    self.type = node.type
  }
}

final class StackReconciler {
  /// A map from a fully qualified component type name and its state hook id
  /// to a current state value.
  var state = [Pair<String, Int>: Any]()

  let root: NodeReference

  func reconcile(node reference: NodeReference, with node: Node) {
  }

  init(root: Node) {
    self.root = NodeReference(node: root)
  }
}
