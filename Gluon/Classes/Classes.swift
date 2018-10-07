//
//  RequiredInit.swift
//  FBSnapshotTestCase
//
//  Created by Max Desiatov on 07/10/2018.
//

import Foundation

protocol Default {
  init()
}

struct Unique<T>: Equatable {
  private let uuid = UUID()
  private let boxed: T

  init(_ boxed: T) {
    self.boxed = boxed
  }

  static func == (lhs: Unique<T>, rhs: Unique<T>) -> Bool {
    return lhs.uuid == rhs.uuid
  }
}

struct NoProps: Equatable, Default {
}

private protocol ComponentType {
}

extension String: ComponentType {
}

class BaseComponent<Props: Equatable>: ComponentType {
  private(set) var props: Props
  private(set) var children: [Node]

  required init(props: Props, children: [Node]) {
    self.props = props
    self.children = children
  }

  static func node(_ props: Props, childrenFactory: () -> [Node]) -> Node {
    let children = childrenFactory()
    return Node {
      self.init(props: props, children: children)
    }
  }

  static func node(_ props: Props, childFactory: () -> Node) -> Node {
    // applying `childFactory` here to avoid `@escaping` attribute
    let child = childFactory()
    return Node { self.init(props: props, children: [child]) }
  }

  static func node(_ props: Props) -> Node {
    return Node { self.init(props: props, children: []) }
  }
}

extension BaseComponent where Props: Default {
  static func node(childrenFactory: () -> [Node]) -> Node {
    return self.node(Props(), childrenFactory: childrenFactory)
  }

  static func node(childFactory: () -> Node) -> Node {
    return self.node(Props(), childFactory: childFactory)
  }

  static func node() -> Node {
    return Node { self.init(props: Props(), children: []) }
  }
}

struct Node {
  fileprivate let factory: () -> ComponentType
}

extension Node: ExpressibleByStringLiteral {
  init(stringLiteral: String) {
    factory = { stringLiteral }
  }
}

extension Node {
  init(_ string: String) {
    factory = { string }
  }
}

class View: BaseComponent<NoProps> {
}

class Label: BaseComponent<Label.Props> {
  struct Props: Equatable, Default {
    let fontColor = UIColor.black
  }
}

class Button: BaseComponent<Button.Props> {
  struct Props: Equatable {
    let backgroundColor = UIColor.white
    let fontColor = UIColor.black
    let onPress: Unique<() -> ()>
  }
}

protocol CompositeComponent {
  func render() -> Node
}

protocol StateType: Default & Equatable {
}

class StatefulComponent<Props: Equatable, State: StateType>: BaseComponent<Props> {
  private(set) var state: State

  required init(props: Props, children: [Node]) {
    state = State()
    super.init(props: props, children: children)
  }

  func setState(setter: (inout State) -> ()) {

  }
}

typealias Component<P: Equatable, S: StateType> =
  StatefulComponent<P, S> & CompositeComponent
