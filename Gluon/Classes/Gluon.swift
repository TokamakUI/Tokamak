//
//  Gluon.swift
//  Gluon_Example
//
//  Created by Max Desiatov on 15/09/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

protocol KeyPathListable {
    // require empty init as the implementation use the mirroring API, which require
    // to be used on an instance. So we need to be able to create a new instance of the
    // type.
    init()

    var _keyPathReadableFormat: [String: Any] { get }
    static var allKeyPaths: [KeyPath<Foo, Any?>] { get }
}

extension KeyPathListable {
    var _keyPathReadableFormat: [String: Any] {
        let mirror = Mirror(reflecting: self)
        var description: [String: Any] = [:]
        for case let (label?, value) in mirror.children {
            description[label] = value
        }
        return description
    }

    static var allKeyPaths: [KeyPath<Self, Any?>] {
        var keyPaths: [KeyPath<Self, Any?>] = []
        let instance = Self()
        for (key, _) in instance._keyPathReadableFormat {
            keyPaths.append(\Self._keyPathReadableFormat[key])
        }
        return keyPaths
    }
}

protocol Diffable: KeyPathListable {
}

struct Foo: KeyPathListable {
    var x: Int
    var y: Int
}

protocol GluonProp: Hashable {
}

protocol GluonState {
    init()
}

protocol AnyBaseComponent {
}

protocol AnyComponent {
    func render() -> AnyGluonNode
}

class BaseComponent<P: GluonProp, S: GluonState>: AnyBaseComponent {
    var props: Set<P> = []
    var state = S()
}

typealias Component<P: GluonProp, S: GluonState> = BaseComponent<P, S> & AnyComponent

//  protocol Gluon: Component {
//      func render() -> AnyGluonNode
//  }

extension BaseComponent {
    static func node(_ props: Set<P> = [],
                     _ children: [AnyGluonNode] = []) -> GluonNode<P> {
        return GluonNode(self, props, children)
    }
}

protocol AnyGluonNode {}

struct GluonNode<P>: AnyGluonNode
where P: GluonProp {
    let component: AnyBaseComponent.Type
    let props: Set<P>
    let children: [AnyGluonNode]

    init(_ component: AnyBaseComponent.Type,
         _ props: Set<P>,
         _ children: [AnyGluonNode]) {
        self.component = component
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

