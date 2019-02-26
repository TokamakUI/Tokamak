//
//  SnakeGame.swift
//  TokamakDemo
//
//  Created by Matvii Hodovaniuk on 2/25/19.
//  Copyright © 2019 Tokamak. All rights reserved.
//

import Tokamak

struct SnakeGame: LeafComponent {
  typealias Props = Null

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let snakeProps = Snake.Props(cellSize: 10, mapSizeInCells: Size(width: 20, height: 20))

    return View.node(
      .init(
        Style(
          Edges.equal(to: .safeArea),
          backgroundColor: .white
        )
      ), [
        Snake.node(snakeProps),
      ]
    )
  }
}
