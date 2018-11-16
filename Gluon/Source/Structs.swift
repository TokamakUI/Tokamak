//
//  ValueTypes.swift
//  Gluon
//
//  Created by Max Desiatov on 07/10/2018.
//

import Foundation

protocol BaseComponent {
}

protocol Component {
  associatedtype Props: Equatable
  associatedtype Children: Equatable

  static func render(_ props: Props, _ children: Children)
}

protocol LeafComponent: Component where Children == NoProps {
  static func render(_ props: Props)
}

extension LeafComponent {
  static func render(_ props: Props, _ children: NoProps) {
    render(props)
  }
}

struct Hooks {
  func state<T>(_ initial: T,
                id: String = "\(#file)\(#line)") -> (T, (T) -> ()) {
    return (initial, { _ in })
  }
}

private let _hooks = Hooks()

extension Component {
  var hooks: Hooks {
    return _hooks
  }
}

protocol BaseComponentType {
  var children: [Node] { get }

  init?(props: AnyEquatable, children: [Node])
}

public struct Node: Equatable {
  /// Equatable can't be automatically derived for recursive types
  public static func == (lhs: Node, rhs: Node) -> Bool {
    return lhs.type == rhs.type &&
      lhs.children == rhs.children &&
      lhs.props == rhs.props
  }

  let props: AnyEquatable
  let children: [Node]
  let type: BaseComponentType.Type
}

private protocol ComponentType: BaseComponentType {
  associatedtype Props: Equatable
  var props: Props { get }

  init(props: Props, children: [Node])
}

extension ComponentType {
  init?(props: AnyEquatable, children: [Node]) {
    guard let props = props.value as? Props else {
      return nil
    }

    self.init(props: props, children: children)
  }

  static func node(props: Props, children: () -> [Node]) -> Node {
    return Node(props: AnyEquatable(props), children: children(), type: self.self)
  }
}

private struct View: ComponentType {
  var props: Props
  var children: [Node]

  struct Props: Equatable {
  }
}

private struct Label: ComponentType {
  var props: Props
  var children: [Node]

  struct Props: Equatable {
  }
}

private struct Button: ComponentType {
  var props: Props
  var children: [Node]

  struct Props: Equatable {
    let backgroundColor = Color.white
    let fontColor = Color.black
    let onPress: Unique<() -> ()>
  }
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
private struct Test: StatefulComponent {
  struct Props: Equatable {
  }
  var props: Props

  struct State: Default {
    var counter = 0
  }
  var state: State
  var children: [Node]

  func onPress() {
    setState { $0.counter += 1 }
  }

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
}
