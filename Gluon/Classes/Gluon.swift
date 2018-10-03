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

class BaseComponent<P: Equatable, S: Default> {
  private(set) var props: P
  private(set) var state: S

  init(props: P, state: S) {
    self.props = props
    self.state = state
  }

  static func node(_ p: P,
                   _ c: [NodeType] = []) -> NodeType {
    return Node(component: self, props: p, children: c)
  }
}

protocol NodeType {
}

struct Node<P, S>: NodeType
where P: Equatable, S: Default {
  let component: BaseComponent<P, S>.Type
  let props: P
  let children: [NodeType]
}

extension UIControl.State: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(rawValue)
  }
}

final class Button: BaseComponent<Button.Props, Button.State> {
  struct Props: Equatable {
    let backgroundColor: UIColor
    let titles: [UIControl.State: String]
  }

  struct State: Default {
  }
}

//final class Button: BaseComponent<ButtonProp> {
//}
//
//enum TestProp: GluonProp {
//  case prop(Int)
//}
//
//final class TestComponent: Component<TestProp> {
//    func render() -> AnyGluonNode {
////        if props
//        return Button.node()
//    }
//}

//typealias Stateless<P1> = (P) -> GluonNode<P> where P: GluonProp

//let stateless = { (p: TestProp) in
//  return Button.node()
//}

//let f: Stateless<TestProps> = stateless

