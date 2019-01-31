//
//  StackPresenter.swift
//  Gluon
//
//  Created by Max Desiatov on 31/12/2018.
//

public struct NavigationItem: Equatable {
  /// The mode to use when displaying the title of the navigation bar.
  public enum TitleMode {
    case automatic
    case large
    case standard
  }

  public let title: String?
  public let titleMode: TitleMode
}

public protocol StackRouter: Router {
  static func route(
    props: Props,
    route: Route,
    push: @escaping (Route) -> (),
    pop: @escaping () -> (),
    hooks: Hooks
  ) -> (NavigationItem?, AnyNode)
}

public protocol SimpleStackRouter: StackRouter {
  static func route(
    props: Props,
    route: Route,
    push: @escaping (Route) -> (),
    pop: @escaping () -> (),
    hooks: Hooks
  ) -> AnyNode
}

extension SimpleStackRouter {
  public static func route(
    props: Props,
    route: Route,
    push: @escaping (Route) -> (),
    pop: @escaping () -> (),
    hooks: Hooks
  ) -> (NavigationItem?, AnyNode) {
    return (
      nil, self.route(
        props: props,
        route: route,
        push: push,
        pop: pop,
        hooks: hooks
      )
    )
  }
}

public struct StackPresenter<T: StackRouter>: LeafComponent {
  public struct Props: Equatable {
    public let hidesBarsWhenKeyboardAppears: Bool?
    public let initial: T.Route
    public let popAnimated: Bool
    public let pushAnimated: Bool
    public let routerProps: T.Props

    public init(
      hidesBarsWhenKeyboardAppears: Bool? = nil,
      initial: T.Route,
      popAnimated: Bool = true,
      pushAnimated: Bool = true,
      routerProps: T.Props
    ) {
      self.hidesBarsWhenKeyboardAppears = hidesBarsWhenKeyboardAppears
      self.initial = initial
      self.popAnimated = popAnimated
      self.pushAnimated = pushAnimated
      self.routerProps = routerProps
    }
  }

  public static func render(props: Props, hooks: Hooks) -> AnyNode {
    let stack = hooks.state([props.initial])

    let pop = { stack.set(Array(stack.value.dropLast())) }

    return StackController.node(
      .init(
        hidesBarsWhenKeyboardAppears: props.hidesBarsWhenKeyboardAppears,
        popAnimated: props.popAnimated,
        pushAnimated: props.pushAnimated,
        onPop: Handler(pop)
      ),
      stack.value.map {
        let pair = T.route(
          props: props.routerProps,
          route: $0,
          push: { stack.set(stack.value + [$0]) },
          pop: pop,
          hooks: hooks
        )

        return StackControllerItem.node(pair.0, pair.1)
      }
    )
  }
}

extension StackPresenter.Props where T.Props == Null {
  public init(
    hidesBarsWhenKeyboardAppears: Bool? = nil,
    initial: T.Route,
    popAnimated: Bool = true,
    pushAnimated: Bool = true
  ) {
    self.hidesBarsWhenKeyboardAppears = hidesBarsWhenKeyboardAppears
    self.initial = initial
    self.popAnimated = popAnimated
    self.pushAnimated = pushAnimated
    routerProps = Null()
  }
}
