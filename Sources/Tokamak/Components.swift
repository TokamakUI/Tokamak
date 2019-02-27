//
//  Component.swift
//  Tokamak
//
//  Created by Max Desiatov on 07/10/2018.
//

/// Type-erased version of `HostComponent` to work around [PAT restrictions](
/// http://www.russbishop.net/swift-associated-types). Users
/// of Tokamak shouldn't ever need to conform to this protocol directly, use
/// `HostComponent` instead.
public protocol AnyHostComponent {}

public protocol HostComponent: AnyHostComponent, Component {}

public protocol AnyRefComponent {
  static func update(ref: AnyObject, with value: Any)
}

public protocol RefComponent: AnyRefComponent, HostComponent {
  associatedtype RefTarget
}

extension AnyRefComponent where Self: RefComponent {
  public static func update(ref: AnyObject, with value: Any) {
    guard let ref = ref as? Ref<RefTarget?>,
      let value = value as? RefTarget else {
      assertionFailure("failed to cast objects passed to \(#function)")
      return
    }

    ref.value = value
  }
}

/// Type-erased version of `CompositeComponent` to work around
/// [PAT restrictions](http://www.russbishop.net/swift-associated-types). Users
/// of Tokamak shouldn't ever need to conform to this protocol directly, use
/// `CompositeComponent` instead.
public protocol AnyCompositeComponent {
  static func render(
    props: AnyEquatable,
    children: AnyEquatable,
    hooks: Hooks
  ) -> AnyNode
}

public protocol Component {
  associatedtype Props: Equatable
  associatedtype Children: Equatable

  static func node(
    _ props: Props,
    _ children: Children
  ) -> AnyNode
}

public protocol CompositeComponent: AnyCompositeComponent, Component {
  static func render(
    props: Props,
    children: Children,
    hooks: Hooks
  ) -> AnyNode
}

public extension CompositeComponent {
  /// Default implementation of `AnyCompositeComponent` that delegates to
  /// `render` requirement in `CompositeComponent` PAT.
  static func render(
    props: AnyEquatable,
    children: AnyEquatable,
    hooks: Hooks
  ) -> AnyNode {
    guard let props = props.value as? Props,
      let children = children.value as? Children else {
      fatalError("""
        incorrect types of `props` and `children` arguments passed to
        `AnyComponent.render`
      """)
    }
    return render(props: props, children: children, hooks: hooks)
  }
}

public protocol PureComponent: CompositeComponent {
  static func render(props: Props, children: Children) -> AnyNode
}

public extension PureComponent {
  static func render(
    props: Props,
    children: Children,
    hooks: Hooks
  ) -> AnyNode {
    return render(props: props, children: children)
  }
}

public protocol LeafComponent: CompositeComponent where Children == Null {
  static func render(props: Props, hooks: Hooks) -> AnyNode
}

public extension LeafComponent {
  static func render(
    props: Props,
    children _: Children,
    hooks: Hooks
  ) -> AnyNode {
    return render(props: props, hooks: hooks)
  }
}

public protocol PureLeafComponent: LeafComponent {
  static func render(props: Props) -> AnyNode
}

public extension PureLeafComponent {
  static func render(props: Props, hooks: Hooks) -> AnyNode {
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
