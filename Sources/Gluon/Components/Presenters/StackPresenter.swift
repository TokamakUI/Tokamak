//
//  StackPresenter.swift
//  Gluon
//
//  Created by Max Desiatov on 31/12/2018.
//

public protocol StackRouter: Router {
  static func route(
    props: Props,
    route: Route,
    push: (Route) -> (),
    pop: () -> ()
  ) -> AnyNode
}

public struct StackPresenter<T: StackRouter>: HostComponent {
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

  public typealias Children = Null
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
