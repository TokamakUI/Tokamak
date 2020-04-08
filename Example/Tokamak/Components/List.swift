//
//  List.swift
//  TokamakDemo
//
//  Created by Max Desiatov on 14/02/2019.
//  Copyright © 2019 Max Desiatov. Tokamak is available under the Apache 2.0
//  license. See the LICENSE file for more info.
//

import Tokamak

private struct Cells: CellProvider {
  static func cell(
    props: Null,
    item: AppRoute,
    path: CellPath
  ) -> AnyNode {
    Label.node(.init(
      Style(
        [CenterY.equal(to: .parent),
         Height.equal(to: 44),
         Leading.equal(to: .safeArea, constant: 20)]
      ),
      text: "\(item.description)"
    ))
  }

  typealias Props = Null

  typealias Model = AppRoute
}

struct List: PureLeafComponent {
  struct Props: Equatable {
    let model: [AppRoute]
    let onSelect: Handler<CellPath>
  }

  static func render(props: Props) -> AnyNode {
    ListView<Cells>.node(.init(
      Style([
        Edges.equal(to: .parent),
      ]),
      model: [props.model],
      onSelect: props.onSelect
    ))
  }
}
