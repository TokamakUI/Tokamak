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

  public func isSubtypeOf<T>(_: T.Type) -> Bool {
    return type.host is T.Type || type.composite is T.Type
  }

  public func isSubtypeOf<T, U>(_: T.Type, or: U.Type) -> Bool {
    return isSubtypeOf(T.self) || isSubtypeOf(U.self)
  }

  public func isSubtypeOf<T, U, V>(
    _: T.Type,
    or _: U.Type,
    or _: V.Type
  ) -> Bool {
    return isSubtypeOf(T.self) || isSubtypeOf(U.self) || isSubtypeOf(V.self)
  }
}

extension Component {
  public static func node(_ props: Props, _ children: Children) -> Node {
    return node(key: nil, props, children)
  }
}

extension Component where Props: Default, Props.DefaultValue == Props {
  public static func node(_ children: Children) -> Node {
    return node(Props.defaultValue, children)
  }
}

extension Component where Children == Null {
  public static func node(_ props: Props) -> Node {
    return node(props, Null())
  }
}

extension Component where Children == [Node] {
  public static func node(_ props: Props,
                          _ child: Node) -> Node {
    return node(props, [child])
  }
}

extension HostComponent {
  public static func node(key: String?,
                          _ props: Props,
                          _ children: Children) -> Node {
    return Node(key: key,
                props: AnyEquatable(props),
                children: AnyEquatable(children),
                type: .host(self))
  }
}

extension CompositeComponent {
  public static func node(key: String?,
                          _ props: Props,
                          _ children: Children) -> Node {
    return Node(key: key,
                props: AnyEquatable(props),
                children: AnyEquatable(children),
                type: .composite(self))
  }
}
