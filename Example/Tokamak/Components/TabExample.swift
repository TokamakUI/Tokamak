//
//  TabExample.swift
//  TokamakDemo-iOS
//
//  Created by Matvii Hodovaniuk on 3/13/19.
//  Copyright © 2019 Tokamak contributors. Tokamak is available under the Apache 2.0
//  license. See the LICENSE file for more info.
//

import Tokamak

// struct ExampleTabRouter: TabRouter {
//  static func route(props: ExampleTabRouter.Props, route: ExampleTabRouter.Route, hooks: Hooks) -> AnyNode {
//    return TabItem
//  }
//
////  static func route(props: ExampleTabRouter.Props, route: ExampleTabRouter.Route, hooks: Hooks) -> AnyNode {
////    return TabItem.node(.init(title: ""))
////  }
//
//  enum Route {
//    case first
//    case second
//  }
//
//  struct Props: Equatable {
//    let onPress: Handler<()>
//  }
//
//  static func route(
//    props: Props,
//    route: Route,
//    //    push: @escaping (Route) -> (),
////    pop: @escaping () -> (),
//    hooks _: Hooks
//  ) -> TabItem {
//    return TabItem(title: "Title")
////    let close =
////      Button.node(.init(
////        Style(Rectangle(.zero, Size(width: 200, height: 200))),
////        onPress: props.onPress,
////        text: "Close Modal"
////        ))
////    switch route {
////    case .first:
////      return
////        NavigationItem.node(
////          .init(title: "First", titleMode: .standard),
////          View.node(
////            .init(Style(Edges.equal(to: .parent), backgroundColor: .white)), [
////              close,
////              Button.node(.init(
////                Style(Rectangle(Point(x: 0, y: 400),
////                                Size(width: 200, height: 200))),
////                onPress: Handler { push(.second) },
////                text: "Go to Second"
////                )),
////              ]
////          )
////      )
////    case .second:
////      return
////        NavigationItem.node(
////          .init(title: "Second", titleMode: .large),
////          View.node(
////            .init(Style(Edges.equal(to: .parent), backgroundColor: .white)), [
////              close,
////              Label.node(.init(
////                Style(Rectangle(Point(x: 0, y: 200),
////                                Size(width: 200, height: 200))),
////                alignment: .center,
////                text: "This is second"
////                )),
////              ]
////          )
////      )
////    }
//  }
// }

struct TabExample: PureLeafComponent {
  typealias Props = Null

  static func render(props: Props) -> AnyNode {
    return TabController.node(
      .init(),
      [Label.node("First")]
    )
  }
}
