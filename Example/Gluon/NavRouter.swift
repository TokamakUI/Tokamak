//
//  NavRouter.swift
//  Gluon_Example
//
//  Created by Max Desiatov on 29/01/2019.
//  Copyright © 2019 Gluon. All rights reserved.
//

import Gluon

struct NavRouter: SimpleStackRouter {
  enum Route {
    case first
    case second
  }

  struct Props: Equatable {
    let onPress: Handler<()>
  }

  static func route(
    props: Props,
    route: Route,
    push: @escaping (Route) -> (),
    pop: @escaping () -> (),
    hooks _: Hooks
  ) -> AnyNode {
    let close =
      Button.node(.init(
        onPress: props.onPress,
        Style(Rectangle(.zero, Size(width: 200, height: 200)))
      ), "Close Modal")
    switch route {
    case .first:
      return View.node(
        .init(Style(backgroundColor: .white)), [
          close,
          Label.node(.init(
            alignment: .center,
            Style(Rectangle(Point(x: 0, y: 200),
                            Size(width: 200, height: 200)))
          ), "first"),
          Button.node(.init(
            onPress: Handler { push(.second) },
            Style(Rectangle(Point(x: 0, y: 400),
                            Size(width: 200, height: 200)))
          ), "second"),
        ]
      )
    case .second:
      return View.node(
        .init(Style(backgroundColor: .white)), [
          close,
          Label.node(.init(
            alignment: .center,
            Style(Rectangle(Point(x: 0, y: 200),
                            Size(width: 200, height: 200)))
          ), "second"),
        ]
      )
    }
  }
}
