//
//  Node.swift
//  Gluon
//
//  Created by Max Desiatov on 30/11/2018.
//

public struct Node: Equatable {
  /// Equatable can't be automatically derived for `type` property?
  public static func == (lhs: Node, rhs: Node) -> Bool {
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

extension BaseComponent {
  public static func node(key: String? = nil,
                          _ props: Props,
                          _ children: Children) -> Node {
    return Node(key: key,
                props: AnyEquatable(props),
                children: AnyEquatable(children),
                type: .base(self))
  }
}

extension Node: ChildrenType {
}

extension Array: ChildrenType where Element == Node {
}

extension String: ChildrenType {
}
