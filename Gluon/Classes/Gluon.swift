//
//  Gluon.swift
//  Gluon_Example
//
//  Created by Max Desiatov on 15/09/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

protocol Default {
  init()
}

protocol NodeType: Equatable {
}

struct AnyNode: NodeType {
  let value: Any
  private let equals: (Any) -> Bool

  public init<E: NodeType>(_ value: E) {
    self.value = value
    self.equals = { ($0 as? E) == value }
  }

  public static func == (lhs: AnyNode, rhs: AnyNode) -> Bool {
    return lhs.equals(rhs.value) || rhs.equals(lhs.value)
  }
}

extension NodeType {
  var wrap: AnyNode {
    return AnyNode(self)
  }
}

extension UIControl.State: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(rawValue)
  }
}

class BaseComponent<Node: NodeType> {
  var node: Node

  init(node: Node) {
    self.node = node
  }
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

final class View: BaseComponent<View.Node> {
  struct Node: NodeType {
    let children: [AnyNode]
    init(children: () -> [AnyNode]) {
      self.children = children()
    }
  }
}

final class Label: BaseComponent<Label.Node> {
  struct Node: NodeType {
    let children: String
  }
}

final class Button: BaseComponent<Button.Node> {
  struct Node: NodeType {
    let backgroundColor = UIColor.white
    let onPress: Unique<() -> ()>
    let children: String
  }
}

class Component<Node: NodeType, State: Default>: BaseComponent<Node> {
  private(set) var state: State

  init(node: Node, state: State) {
    self.state = state
    super.init(node: node)
  }

  func setState(setter: (inout State) -> ()) {

  }

  func render() -> AnyNode {
    fatalError("Component subclass should override render()")
  }
}

struct NoProps: NodeType {
}

final class Test: Component<NoProps, Test.State> {
  struct State: Default {
    var counter = 0
  }

  func onPress() {
    setState { $0.counter += 1 }
  }

  lazy var onPressHandler = { Unique { self.onPress() } }()

  override func render() -> AnyNode {
    return AnyNode(View.Node {
      [
        Button.Node(onPress: onPressHandler, children: "Tap Me").wrap,
        Label.Node(children: "\(state)").wrap
      ]
    })
  }
}

func render(node: AnyNode, container: UIView) {
}

