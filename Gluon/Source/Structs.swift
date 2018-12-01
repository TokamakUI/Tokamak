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

/// Conforming to this protocol, but implementing support for these new types
/// in a renderer would make that renderer skip unknown types of children.
public protocol ChildrenType {
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
  associatedtype Children: Equatable

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

// well, this gets problematic:
// 1. `props` needs to be `var` for renderer to update them from node updates,
//    but this means `StatefulComponent` implementor is compelled to modify
//    `props` directly
// 2. Same for `state`, but how would you even implement `setState` if there's
//    no dependency injection point for a renderer?
// 3. Maybe `getState` and `setState` could be closures that are assigned by
//    the renderer? How does a renderer set up a heterogenous state store for
//    all components then?
// 4. Could ability to have stored properties in extensions make this any
//    better?
//private struct Test: StatefulComponent {
//  struct Props: Equatable {
//  }
//  var props: Props
//
//  struct State: Default {
//    var counter = 0
//  }
//  var state: State
//  var children: [Node]
//
//  func onPress() {
//    setState { $0.counter += 1 }
//  }
//
// getting an error "Closure cannot implicitly capture a mutating self parameter"
// if this is uncommented
//  lazy var onPressHandler = { Unique { onPress() } }()
//
//  override func render() -> AnyNode {
//    return AnyNode(View.Node {
//      [
//        Button.Node(onPress: onPressHandler, children: "Tap Me").wrap,
//        Label.Node(children: "\(state)").wrap
//      ]
//    })
//  }
//}
