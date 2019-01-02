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
  public let props: AnyEquatable
  public let children: AnyEquatable
  let type: ComponentType

  public func isOf(type: Any.Type) -> Bool {
    return self.type.host == type || self.type.composite == type
  }

  public func isOf(types: [Any.Type]) -> Bool {
    return types.contains { isOf(type: $0) }
  }
}

extension HostComponent {
  public static func node(key: String? = nil,
                          _ props: Props,
                          _ children: Children) -> Node {
    return Node(key: key,
                props: AnyEquatable(props),
                children: AnyEquatable(children),
                type: .host(self))
  }
}

extension HostComponent where Children == Null {
  public static func node(key: String? = nil,
                          _ props: Props) -> Node {
    return node(key: key, props, Null())
  }
}

extension HostComponent where Children == [Node] {
  public static func node(key: String? = nil,
                          _ props: Props,
                          _ child: Node) -> Node {
    return node(key: key, props, [child])
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
