//
//  List.swift
//  Tokamak_Example
//
//  Created by Max Desiatov on 14/02/2019.
//  Copyright © 2019 Max Desiatov. All rights reserved.
//

import Tokamak

private struct Cells: SimpleCellProvider {
  static func cell(
    props: Null,
    item: AppRoute,
    path: CellPath
  ) -> AnyNode {
    return Label.node(.init(
      Style(
        [CenterY.equal(to: .parent),
         Height.equal(to: 44),
         Leading.equal(to: .safeArea, constant: 20)]
      ),
      text: "\(item.description)"
    ))
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
      Style([
        Edges.equal(to: .parent),
      ]),
      model: [props.model],
      onSelect: props.onSelect
    ))
  }
}
