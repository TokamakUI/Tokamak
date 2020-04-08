//
//  Node.swift
//  Tokamak
//
//  Created by Max Desiatov on 30/11/2018.
//

public struct AnyNode: Equatable {
  // Equatable can't be automatically derived for `type` property?
  public static func ==(lhs: AnyNode, rhs: AnyNode) -> Bool {
    lhs.type == rhs.type &&
      lhs.children == rhs.children &&
      lhs.props == rhs.props &&
      lhs.ref === rhs.ref
  }

  public let props: AnyEquatable
  public let children: AnyEquatable
  let type: ComponentType
  public let ref: AnyObject?

  public func isSubtypeOf<T>(_: T.Type) -> Bool {
    type.host is T.Type || type.composite is T.Type
  }

  public func isSubtypeOf<T, U>(_: T.Type, or: U.Type) -> Bool {
    isSubtypeOf(T.self) || isSubtypeOf(U.self)
  }

  public func isSubtypeOf<T, U, V>(
    _: T.Type,
    or _: U.Type,
    or _: V.Type
  ) -> Bool {
    isSubtypeOf(T.self) || isSubtypeOf(U.self) || isSubtypeOf(V.self)
  }
}

extension Null {
  public static func node() -> AnyNode {
    AnyNode(
      props: AnyEquatable(Null()),
      children: AnyEquatable(Null()),
      type: .null,
      ref: nil
    )
  }
}

extension Component where Children == Null {
  public static func node(_ props: Props) -> AnyNode {
    node(props, Null())
  }
}

extension Component where Props == Null, Children == Null {
  public static func node() -> AnyNode {
    node(Null(), Null())
  }
}

extension Component where Props: Default, Props.DefaultValue == Props {
  public static func node(_ children: Children) -> AnyNode {
    node(Props.defaultValue, children)
  }
}

extension Component where Children == [AnyNode] {
  public static func node(_ props: Props,
                          _ child: AnyNode) -> AnyNode {
    node(props, [child])
  }

  public static func node(_ props: Props) -> AnyNode {
    node(props, [])
  }
}

extension Component where Props == Null, Children == [AnyNode] {
  public static func node() -> AnyNode {
    node(Null(), [])
  }
}

extension Component where Props: Default, Props.DefaultValue == Props,
  Children == [AnyNode] {
  public static func node(_ child: AnyNode) -> AnyNode {
    node(Props.defaultValue, [child])
  }

  public static func node() -> AnyNode {
    node(Props.defaultValue, [])
  }
}

extension HostComponent {
  public static func node(_ props: Props, _ children: Children) -> AnyNode {
    AnyNode(
      props: AnyEquatable(props),
      children: AnyEquatable(children),
      type: .host(self),
      ref: nil
    )
  }
}

extension CompositeComponent {
  public static func node(
    _ props: Props,
    _ children: Children
  ) -> AnyNode {
    AnyNode(
      props: AnyEquatable(props),
      children: AnyEquatable(children),
      type: .composite(self),
      ref: nil
    )
  }
}

extension RefComponent {
  public static func node(
    _ props: Props,
    _ children: Children,
    ref: Ref<RefTarget?>
  ) -> AnyNode {
    AnyNode(
      props: AnyEquatable(props),
      children: AnyEquatable(children),
      type: .host(self),
      ref: ref
    )
  }
}

extension RefComponent where Children == [AnyNode] {
  public static func node(
    _ props: Props,
    _ child: AnyNode,
    ref: Ref<RefTarget?>
  ) -> AnyNode {
    node(props, [child], ref: ref)
  }

  public static func node(_ props: Props, ref: Ref<RefTarget?>) -> AnyNode {
    node(props, [], ref: ref)
  }
}

extension RefComponent where Children == Null {
  public static func node(_ props: Props, ref: Ref<RefTarget?>) -> AnyNode {
    node(props, Null(), ref: ref)
  }
}

extension RefComponent where Props: Default, Props.DefaultValue == Props {
  public static func node(
    _ children: Children,
    ref: Ref<RefTarget?>
  ) -> AnyNode {
    node(Props.defaultValue, children, ref: ref)
  }
}
