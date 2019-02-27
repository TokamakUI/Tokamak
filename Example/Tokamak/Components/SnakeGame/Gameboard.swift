//
//  Gameboard.swift
//  TokamakDemo
//
//  Created by Matvii Hodovaniuk on 2/27/19.
//  Copyright © 2019 Tokamak. All rights reserved.
//

import Tokamak

struct Gameboard: PureComponent {
  struct Props: Equatable {
    let game: State<Game>
    let cellSize: Double
  }

  typealias Children = [AnyNode]

  static func render(props: Props, children: Children) -> AnyNode {
    let game = props.game

    return View.node(
      [
        View.node(
          .init(Style(
            [
              Center.equal(to: .parent),
              Width.equal(
                to: props.cellSize * game.value.mapSize.width
              ),
              Height.equal(
                to: props.cellSize * game.value.mapSize.height
              ),
            ],
            borderColor: .black,
            borderWidth: 2
          )),
          [
            View.node(
              GameCell.node(.init(
                color: .red,
                size: props.cellSize,
                location: game.value.target
              ))
            ),
            View.node(
              game.value.snake.map { (location) -> AnyNode in
                let props = GameCell.Props(
                  color: .black,
                  size: props.cellSize,
                  location: location
                )
                return GameCell.node(props)
              }
            ),
          ]
        ),
      ]
    )
  }
}
