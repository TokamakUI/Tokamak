//
//  TabPresenter.swift
//  Tokamak
//
//  Created by Max Desiatov on 31/12/2018.
//

public protocol TabRouter: Router {
  static func route(
    props: Props,
    route: Route,
    hooks: Hooks
  ) -> AnyNode
}

public struct TabPresenter<T: TabRouter>: LeafComponent {
  public struct Props: Equatable {
    public let initial: T.Route
    public let routerProps: T.Props

    public init(
      initial: T.Route,
      routerProps: T.Props
    ) {
      self.initial = initial
      self.routerProps = routerProps
    }
  }

  public static func render(props: Props, hooks: Hooks) -> AnyNode {
    let stack = hooks.state([props.initial])

    return TabController.node(
      .init(
        isAnimated: true
      ),
      stack.value.map {
        T.route(
          props: props.routerProps,
          route: $0,
          hooks: hooks
        )
      }
    )
  }
}

extension TabPresenter.Props where T.Props == Null {
  public init(
    initial: T.Route
  ) {
    self.initial = initial
    routerProps = Null()
  }
}
