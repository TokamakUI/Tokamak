//
//  NavigationPresenter.swift
//  Tokamak
//
//  Created by Max Desiatov on 31/12/2018.
//

public protocol NavigationRouter {
  associatedtype Props: Equatable
  associatedtype Route: Equatable

  static func route(
    props: Props,
    route: Route,
    push: @escaping (Route) -> (),
    pop: @escaping () -> (),
    hooks: Hooks
  ) -> AnyNode
}

public struct NavigationPresenter<T: NavigationRouter>: LeafComponent {
  public struct Props: Equatable {
    public let hidesBarsWhenKeyboardAppears: Bool?
    public let initial: T.Route
    public let popAnimated: Bool
    public let prefersLargeTitles: Bool
    public let pushAnimated: Bool
    public let routerProps: T.Props

    public init(
      hidesBarsWhenKeyboardAppears: Bool? = nil,
      initial: T.Route,
      popAnimated: Bool = true,
      prefersLargeTitles: Bool = false,
      pushAnimated: Bool = true,
      routerProps: T.Props
    ) {
      self.hidesBarsWhenKeyboardAppears = hidesBarsWhenKeyboardAppears
      self.initial = initial
      self.popAnimated = popAnimated
      self.prefersLargeTitles = prefersLargeTitles
      self.pushAnimated = pushAnimated
      self.routerProps = routerProps
    }
  }

  public static func render(props: Props, hooks: Hooks) -> AnyNode {
    let stack = hooks.state([props.initial])

    let pop = { stack.set { $0.remove(at: $0.count - 1) } }

    return NavigationController.node(
      .init(
        hidesBarsWhenKeyboardAppears: props.hidesBarsWhenKeyboardAppears,
        popAnimated: props.popAnimated,
        prefersLargeTitles: props.prefersLargeTitles,
        pushAnimated: props.pushAnimated,
        onPop: Handler(pop)
      ),
      stack.value.map {
        T.route(
          props: props.routerProps,
          route: $0,
          push: { stack.set(stack.value + [$0]) },
          pop: pop,
          hooks: hooks
        )
      }
    )
  }
}

extension NavigationPresenter.Props where T.Props == Null {
  public init(
    hidesBarsWhenKeyboardAppears: Bool? = nil,
    initial: T.Route,
    popAnimated: Bool = true,
    prefersLargeTitles: Bool = false,
    pushAnimated: Bool = true
  ) {
    self.hidesBarsWhenKeyboardAppears = hidesBarsWhenKeyboardAppears
    self.initial = initial
    self.popAnimated = popAnimated
    self.prefersLargeTitles = prefersLargeTitles
    self.pushAnimated = pushAnimated
    routerProps = Null()
  }
}
