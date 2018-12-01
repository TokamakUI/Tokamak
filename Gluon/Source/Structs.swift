//
//  ValueTypes.swift
//  Gluon
//
//  Created by Max Desiatov on 07/10/2018.
//

import Foundation

extension Never: Equatable {
  public static func == (lhs: Never, rhs: Never) -> Bool {
    switch (lhs, rhs) {
    }
  }
}

public protocol AnyBaseComponent {
}

public protocol BaseComponent: AnyBaseComponent {
  associatedtype Props: Equatable
  associatedtype Children: ChildrenType & Equatable
}

// FIXME: this protocol shouldn't be public, but is there a good workaround?
public protocol AnyCompositeComponent {
  static func render(props: AnyEquatable, children: AnyEquatable) -> Node
}

public protocol CompositeComponent: AnyCompositeComponent {
  associatedtype Props: Equatable
  associatedtype Children: ChildrenType & Equatable

  static func render(props: Props, children: Children) -> Node
}

// FIXME: this extension shouldn't be private too, but
/// `public protocol AnyCompositeComponent` requires this to stay public
public extension CompositeComponent {
  static func render(props: AnyEquatable, children: AnyEquatable) -> Node {
    guard let props = props as? Props,
    let children = children as? Children else {
      fatalError("""
        incorrect types of `props` and `children` arguments passed to
        `AnyComponent.render`
      """)
    }
    return render(props: props, children: children)
  }
}

public protocol LeafComponent: CompositeComponent where Children == Null {
  static func render(props: Props) -> Node
}

public extension LeafComponent {
  public static func render(props: Props, children: Children) -> Node {
    return render(props: props)
  }
}

enum ComponentType: Equatable {
  static func == (lhs: ComponentType, rhs: ComponentType) -> Bool {
    switch (lhs, rhs) {
    case let (.base(ltype), .base(rtype)):
      return ltype == rtype
    case let (.composite(ltype), .composite(rtype)):
      return ltype == rtype
    default:
      return false
    }
  }

  case base(AnyBaseComponent.Type)
  case composite(AnyCompositeComponent.Type)

  var composite: AnyCompositeComponent.Type? {
    guard case let .composite(type) = self else { return nil }

    return type
  }

  var base: AnyBaseComponent.Type? {
    guard case let .base(type) = self else { return nil }

    return type
  }
}

public struct View: BaseComponent {
  public typealias Children = [Node]

  public let props: Props
  public let children: [Node]

  public struct Props: Equatable {
  }
}

public struct Label: BaseComponent {
  public typealias Props = Null
  public typealias Children = String
}

public struct ButtonProps: Equatable {
  let backgroundColor: Color
  let fontColor: Color
  let onPress: Handler<()>

  public init(backgroundColor: Color = .white,
              fontColor: Color = .black,
              onPress: Handler<()>) {
    self.backgroundColor = backgroundColor
    self.fontColor = fontColor
    self.onPress = onPress
  }
}

public struct Button: BaseComponent {
  public typealias Props = ButtonProps
  public typealias Children = String
}

public struct StackView: BaseComponent {
  public typealias Props = Null
  public typealias Children = [Node]
}
