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

/// Type-erased version of Component to work around
/// the lack of generalized existentials in Swift
public protocol _Component {
}

/// Conforming to this protocol, but implementing support for these new types
/// in a renderer would make that renderer skip unknown types of children.
public protocol ChildrenType {
}

/// You should never directly conform to this protocol, use `HostComponent`
/// for host components and `Component` for composite components.
public protocol BaseComponent: _Component {
  associatedtype Props: Equatable
  associatedtype Children: ChildrenType & Equatable

  var children: Children { get }
  var props: Props { get }
}

public protocol Component: _Component {
  associatedtype Props: Equatable
  associatedtype Children: Equatable

  static func render(props: Props, children: Children) -> Node
}

public protocol LeafComponent: Component where Children == Never {
  static func render(props: Props) -> Node
}

public extension LeafComponent {
  public static func render(props: Props, children: Children) -> Node {
    return render(props: props)
  }
}

public struct Hooks {
  public func state<T>(_ initial: T,
                id: String = "\(#file)\(#line)") -> (T, (T) -> ()) {
    return (initial, { _ in })
  }
}

private let _hooks = Hooks()

extension Component {
  public static var hooks: Hooks {
    return _hooks
  }
}

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
  let type: _Component.Type
}

extension BaseComponent {
  public static func node(key: String? = nil,
                          _ props: Props,
                          _ children: Children) -> Node {
    return Node(key: key,
                props: AnyEquatable(props),
                children: AnyEquatable(children),
                type: self.self)
  }
}

extension Node: ChildrenType {
}

extension Array: ChildrenType where Element == Node {
}

extension String: ChildrenType {
}

public struct View: BaseComponent {
  public typealias Children = [Node]

  public let props: Props
  public let children: [Node]

  public struct Props: Equatable {
  }
}

public struct Label: BaseComponent {
  public let props: NoProps
  public let children: String
}

public struct Button: BaseComponent {
  public let props: Props
  public let children: String

  public struct Props: Equatable {
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
}

public struct StackView: BaseComponent {
  public let props: NoProps
  public let children: [Node]
}

// MARK: Legacy

private protocol ComponentType: BaseComponentType {
  associatedtype Props: Equatable
  var props: Props { get }

  init(props: Props, children: [Node])
}

private protocol BaseComponentType {
  var children: [Node] { get }

  init?(props: AnyEquatable, children: [Node])
}

private protocol StatefulComponent: ComponentType {
  associatedtype State: Default

  var state: State { get }

  init(props: Props, state: State, children: [Node])
}

extension StatefulComponent {
  init(props: Props, children: [Node]) {
    self.init(props: props, state: State(), children: children)
  }
}

extension StatefulComponent {
  func setState(setter: (inout State) -> ()) {

  }
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
