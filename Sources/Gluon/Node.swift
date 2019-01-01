//
//  Node.swift
//  Gluon
//
//  Created by Max Desiatov on 30/11/2018.
//

public struct Node: Equatable {
  /// Equatable can't be automatically derived for `type` property?
  public static func ==(lhs: Node, rhs: Node) -> Bool {
    return lhs.key == rhs.key &&
      lhs.type == rhs.type &&
      lhs.children == rhs.children &&
      lhs.props == rhs.props
  }

  let key: String?
  let props: AnyEquatable
  let children: AnyEquatable
  let type: ComponentType
}

extension HostComponent {
  public static func node(key: String? = nil,
                          _ props: Props,
                          _ children: Children) -> Node {
    return Node(key: key,
                props: AnyEquatable(props),
                children: AnyEquatable(children),
                type: .base(self))
  }
}

extension HostComponent where Children == Null {
  public static func node(key: String? = nil,
                          _ props: Props) -> Node {
    return node(key: key, props, Null())
  }
}

extension CompositeComponent {
  public static func node(key: String? = nil,
                          _ props: Props,
                          _ children: Children) -> Node {
    return Node(key: key,
                props: AnyEquatable(props),
                children: AnyEquatable(children),
                type: .composite(self))
  }
}

extension LeafComponent {
  public static func node(key: String? = nil,
                          _ props: Props) -> Node {
    return node(key: key, props, Null())
  }
}

/// A user of Gluon might want to add conformance for this protocol to
/// enable different types of children for their composite components, e.g.
/// Set<Int> or some other useful "model" type.
public protocol ChildrenType {}

extension Null: ChildrenType {}

extension Node: ChildrenType {}

extension Array: ChildrenType where Element == Node {}

extension String: ChildrenType {}
