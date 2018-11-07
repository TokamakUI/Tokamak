//
//  Hooks.swift
//  Gluon
//
//  Created by Max Desiatov on 06/11/2018.
//

protocol Diffable {
  func diffKeyPaths(other: Self) -> [PartialKeyPath<Self>]
}

protocol BaseComponent: Equatable {
}

public struct Component<P: Equatable>: Equatable {
  let id: String
  let base: (P) -> Node

  /// The generated uuid might incur some app start up time penalty. It would
  /// be great if there was a nice way to generate a unique static string.
  /// One approach could be using `"\(#file)\(#line)"` as a default value,
  /// but that leaks absolute filepaths, which is not ideal from a security
  /// perspective.
  public init(id: String = UUID().uuidString, base: @escaping (P) -> Node) {
    self.id = id
    self.base = base
  }

  public static func ==(lhs: Component<P>, rhs: Component<P>) -> Bool {
    return lhs.id == rhs.id
  }
}


public struct Node {
  let component: Any
  let props: Any

  /// Closure with a component rerendered with new props
  let rerenderIfNeeded: (Node) -> Node?

  public init<P: Equatable>(_ component: Component<P>, _ props: P) {
    self.component = component
    self.props = props
    rerenderIfNeeded = {
      guard let newComponent = $0.component as? Component<P>,
      newComponent == component,
      let newProps = $0.props as? P,
      newProps != props else { return nil }

      return component.base(newProps)
    }
  }
}

struct Props: Equatable, Diffable {
  func diffKeyPaths(other: Props) -> [PartialKeyPath<Props>] {
    var result = [PartialKeyPath<Props>]()
    if height != other.height {
      result.append(\Props.height)
    }

    if width != other.width {
      result.append(\Props.width)
    }

    return result
  }

  var height: Double
  var width: Float

  static let kp = [\Props.height, \Props.width]
}
