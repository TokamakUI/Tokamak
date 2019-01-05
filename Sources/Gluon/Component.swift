//
//  Component.swift
//  Gluon
//
//  Created by Max Desiatov on 07/10/2018.
//

// FIXME: this protocol shouldn't be public, but is there a good workaround?
public protocol AnyHostComponent {}

public protocol HostComponent: AnyHostComponent, Component {}

// FIXME: this protocol shouldn't be public, but is there a good workaround?
public protocol AnyCompositeComponent {
  static func render(props: AnyEquatable, children: AnyEquatable) -> AnyNode
}

public protocol Component {
  associatedtype Props: Equatable
  associatedtype Children: Equatable

  static func node(key: String?,
                   _ props: Props,
                   _ children: Children) -> AnyNode
}

public protocol CompositeComponent: AnyCompositeComponent, Component {
  static func render(props: Props, children: Children) -> AnyNode
}

// FIXME: this extension should be private too, but
// `public protocol AnyCompositeComponent` requires this to stay public
public extension CompositeComponent {
  static func render(props: AnyEquatable, children: AnyEquatable) -> AnyNode {
    guard let props = props.value as? Props,
      let children = children.value as? Children else {
      fatalError("""
        incorrect types of `props` and `children` arguments passed to
        `AnyComponent.render`
      """)
    }
    return render(props: props, children: children)
  }
}

public protocol LeafComponent: CompositeComponent where Children == Null {
  static func render(props: Props) -> AnyNode
}

public extension LeafComponent {
  static func render(props: Props, children _: Children) -> AnyNode {
    return render(props: props)
  }
}

enum ComponentType: Equatable {
  static func ==(lhs: ComponentType, rhs: ComponentType) -> Bool {
    switch (lhs, rhs) {
    case let (.host(ltype), .host(rtype)):
      return ltype == rtype
    case let (.composite(ltype), .composite(rtype)):
      return ltype == rtype
    default:
      return false
    }
  }

  case host(AnyHostComponent.Type)
  case composite(AnyCompositeComponent.Type)
  case null

  var composite: AnyCompositeComponent.Type? {
    guard case let .composite(type) = self else { return nil }

    return type
  }

  var host: AnyHostComponent.Type? {
    guard case let .host(type) = self else { return nil }

    return type
  }
}
