//
//  List.swift
//  Gluon_Example
//
//  Created by Max Desiatov on 14/02/2019.
//  Copyright © 2019 Gluon. All rights reserved.
//

import Gluon

private struct Cells: SimpleCellProvider {
  static func cell(
    props: Null,
    item: AppRoute,
    path: CellPath
  ) -> AnyNode {
    return Label.node(.init(Style(
      [CenterY.equal(to: .parent),
       Height.equal(to: 44),
       Leading.equal(to: .safeArea, constant: 20)]
    )), "\(item.description)")
  }

  typealias Props = Null

  typealias Model = [[AppRoute]]
}

struct List: PureLeafComponent {
  struct Props: Equatable {
    let model: [AppRoute]
    let onSelect: Handler<CellPath>
  }

  static func render(props: Props) -> AnyNode {
    return ListView<Cells>.node(.init(
      model: [props.model],
      onSelect: props.onSelect,
      Style([
        Edges.equal(to: .parent),
      ])
    ))
  }
}
