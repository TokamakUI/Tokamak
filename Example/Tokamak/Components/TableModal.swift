//
//  TableModal.swift
//  Tokamak_Example
//
//  Created by Max Desiatov on 13/02/2019.
//  Copyright © 2019 Max Desiatov. All rights reserved.
//

import Tokamak

struct ListProvider: SimpleCellProvider {
  typealias Props = Null
  typealias Model = [[Int]]

  static func cell(props _: Null, item: Int, path _: CellPath) -> AnyNode {
    return Label.node(.init(Style(
      [CenterY.equal(to: .parent),
       Height.equal(to: 44),
       Leading.equal(to: .parent, constant: 20)]
    )), "\(item)")
  }
}

struct TableRouter: NavigationRouter {
  enum Route: Equatable {
    case table
    case value(Int)
  }

  static func route(
    props: Null,
    route: Route,
    push: @escaping (Route) -> (),
    pop: @escaping () -> (),
    hooks: Hooks
  ) -> AnyNode {
    switch route {
    case .table:
      return NavigationItem.node(
        .init(title: "Table"),
        ListView<ListProvider>.node(.init(
          Style(Edges.equal(to: .parent)),
          onSelect: Handler { push(.value($0.item + 1)) },
          singleSection: [1, 2, 3]
        ))
      )
    case let .value(v):
      return View.node(
        .init(Style(
          Edges.equal(to: .parent),
          backgroundColor: .white
        )),
        Label.node(
          .init(Style(Center.equal(to: .parent))),
          "\(v)"
        )
      )
    }
  }

  typealias Props = Null
}

struct TableModal: PureLeafComponent {
  struct Props: Equatable {
    let isPresented: State<Bool>
  }

  static func render(props: Props) -> AnyNode {
    let nav = NavigationPresenter<TableRouter>.node(.init(initial: .table))
    return props.isPresented.value ? ModalPresenter.node(nav) : Null.node()
  }
}
