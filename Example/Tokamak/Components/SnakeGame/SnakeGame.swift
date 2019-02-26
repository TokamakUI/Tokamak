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
//        Cell.node(.init(size: 10, location: Point(x: 10, y: 10))),
    let snakeProps = Snake.Props(cellSize: 10, mapSizeInCells: Size(width: 100, height: 100))

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
