//
//  RootRouter.swift
//  TokamakDemo
//
//  Created by Max Desiatov on 14/02/2019.
//  Copyright © 2019 Max Desiatov. Tokamak is available under the Apache 2.0
//  license. See the LICENSE file for more info.
//

import Tokamak
import TokamakDemo

enum AppRoute: String, CaseIterable {
  case list = "Examples"
//  case counter
  case controls
  case constraints = "Auto Layout Constraints"
  case modals = "Modal Presentation"
  case datePicker = "Date Picker"
  case layerProps = "Layer Props"
  case timer
  case image
  case textField = "Text Field"
  case animation
  case snakeGame = "Snake Game"
  case scrollView = "Scroll"
  case collection = "Collection View"
  case tab = "Tab Example"
}

extension AppRoute: CustomStringConvertible {
  var description: String { return rawValue.localizedCapitalized }
}

struct Router: NavigationRouter {
  typealias Route = AppRoute
  typealias Props = Null

  static func route(
    props: Null,
    route: AppRoute,
    push: @escaping (AppRoute) -> (),
    pop: @escaping () -> (),
    hooks: Hooks
  ) -> AnyNode {
    let result: AnyNode
    switch route {
    case .list:
      let model = AppRoute.allCases.filter { $0 != .list }
      result = List.node(.init(
        model: model,
        onSelect: Handler { push(model[$0.item]) }
      ))
    //    case .counter:
    //      result = Counter.node(.init(countFrom: 1))
    case .controls:
      result = Controls.node()
    case .constraints:
      result = Constraints.node()
    case .modals:
      result = Modals.node()
    case .datePicker:
      result = DatePickers.node()
    case .layerProps:
      result = LayerProps.node()
    case .timer:
      result = TimerCounter.node()
    case .image:
      result = ImageExample.node()
    case .textField:
      result = TextFieldExample.node()
    case .animation:
      result = Animation.node()
    case .snakeGame:
      result = SnakeGame.node()
    case .scrollView:
      result = ScrollViewExample.node()
    case .collection:
      result = CollectionExample.node()
    case .tab:
      result = TabExample.node()
    }

    return NavigationItem.node(
      .init(title: route.description),
      View.node(
        .init(Style(Edges.equal(to: .parent), backgroundColor: .white)),
        result
      )
    )
  }
}
