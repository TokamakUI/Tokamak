//
//  Gluon.swift
//  Gluon_Example
//
//  Created by Max Desiatov on 15/09/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

protocol GluonProp: Hashable {
}

class Component<P: GluonProp> {
    var props: Set<P> = []
}

//  protocol Gluon: Component {
//      func render() -> GluonNode<Prop>
//  }

extension Component {
    static func node(_ props: Set<P> = [],
                     _ children: [AnyGluonNode] = []) -> GluonNode<P> {
        return GluonNode(String(describing: self), props, children)
    }
}

protocol AnyGluonNode {}

struct GluonNode<P>: AnyGluonNode
where P: GluonProp {
    let componentName: String
    let props: Set<P>
    let children: [AnyGluonNode]

    init(_ componentName: String, _ props: Set<P>, _ children: [AnyGluonNode]) {
        self.componentName = componentName
        self.props = props
        self.children = children
    }
}

extension String: AnyGluonNode {
}

enum ButtonProp: GluonProp {
    case backgroundColor(UIColor)
    case textColor(UIColor)
    case disabled(Bool)
}

final class Button: Component<ButtonProp> {
}

  enum TestProps: GluonProp {
      case disabled(Bool)
  }

typealias Stateless<P1> = (P) -> GluonNode<P> where P: GluonProp

let stateless = { (p: TestProps) in
  return Button.node()
}

let f: Stateless<TestProps> = stateless

