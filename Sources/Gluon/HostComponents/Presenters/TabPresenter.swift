//
//  TabPresenter.swift
//  Gluon
//
//  Created by Max Desiatov on 31/12/2018.
//

public protocol TabRouter: Router where Route: CaseIterable {
  static func route(props: Props, route: Route, select: (Route) -> ())
}

public protocol AnyTabPresenter {}

public struct TabPresenter<T: TabRouter>: HostComponent, AnyTabPresenter {
  public struct Props: Equatable {
    public let initial: T.Route
    public let routerProps: T.Props
  }

  public typealias Children = [Node]
}
