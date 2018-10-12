//
//  RequiredInit.swift
//  FBSnapshotTestCase
//
//  Created by Max Desiatov on 07/10/2018.
//

import Foundation

public protocol Default {
  init()
}

public typealias Closure<T> = Unique<T>

public struct Unique<T>: Equatable {
  private let uuid = UUID()
  private let boxed: T

  public init(_ boxed: T) {
    self.boxed = boxed
  }

  public static func == (lhs: Unique<T>, rhs: Unique<T>) -> Bool {
    return lhs.uuid == rhs.uuid
  }
}

public struct NoProps: Equatable, Default {
  public init() {}
}

protocol ComponentType {
}

extension String: ComponentType {
}

open class BaseComponent<Props: Equatable>: ComponentType {
  private(set) var props: Props
  private(set) var children: [Node]

  public required init(props: Props, children: [Node]) {
    self.props = props
    self.children = children
  }

  public static func node(_ props: Props, childrenFactory: () -> [Node]) -> Node {
    let children = childrenFactory()
    return Node {
      self.init(props: props, children: children)
    }
  }

  public static func node(_ props: Props, childFactory: () -> Node) -> Node {
    // applying `childFactory` here to avoid `@escaping` attribute
    let child = childFactory()
    return Node { self.init(props: props, children: [child]) }
  }

  public static func node(_ props: Props) -> Node {
    return Node { self.init(props: props, children: []) }
  }
}

final class Fragment: BaseComponent<NoProps> {
}

extension BaseComponent where Props: Default {
  public static func node(childrenFactory: () -> [Node]) -> Node {
    return self.node(Props(), childrenFactory: childrenFactory)
  }

  public static func node(childFactory: () -> Node) -> Node {
    return self.node(Props(), childFactory: childFactory)
  }

  public static func node() -> Node {
    return Node { self.init(props: Props(), children: []) }
  }
}

public struct Node {
  fileprivate let factory: () -> ComponentType
}

extension Node: ExpressibleByStringLiteral {
  public init(stringLiteral: String) {
    factory = { stringLiteral }
  }
}

extension Node {
  public init(_ string: String) {
    factory = { string }
  }

  public init(_ nodes: [Node]) {
    factory = { Fragment(props: NoProps(), children: nodes) }
  }
}

public final class StackView: BaseComponent<NoProps> {
}

public final class Label: BaseComponent<Label.Props> {
  public struct Props: Equatable, Default {
    let fontColor: UIColor

    public init() {
      fontColor = .black
    }
    
    public init(fontColor: UIColor) {
      self.fontColor = fontColor
    }
  }
}

public final class Button: BaseComponent<Button.Props> {
  public struct Props: Equatable {
    let backgroundColor: UIColor
    let fontColor: UIColor
    let onPress: Unique<() -> ()>

    public init(backgroundColor: UIColor = .white, fontColor: UIColor = .black,
                onPress: Unique<() -> ()>) {
      self.backgroundColor = backgroundColor
      self.fontColor = fontColor
      self.onPress = onPress
    }
  }
}

public protocol CompositeComponent {
  func render() -> Node
}

public protocol StateType: Default & Equatable {
}

open class StatefulComponent<Props: Equatable, State: StateType>:
BaseComponent<Props> {
  public private(set) var state: State

  public required init(props: Props, children: [Node]) {
    state = State()
    super.init(props: props, children: children)
  }

  public func setState(setter: (inout State) -> ()) {

  }
}

public typealias Component<P: Equatable, S: StateType> =
  StatefulComponent<P, S> & CompositeComponent
