//
//  Menu.swift
//  TokamakDemo
//
//  Created by Matvii Hodovaniuk on 2/27/19.
//  Copyright © 2019 Tokamak. Tokamak is available under the Apache 2.0
//  license. See the LICENSE file for more info.
//

import Tokamak

struct GameMenu: PureComponent {
  struct Props: Equatable {
    let game: State<Game>
  }

  typealias Children = [AnyNode]

  static func render(props: Props, children: Children) -> AnyNode {
    let game = props.game

    let restartedGameState = Game(
      state: .isPlaying,
      mapSize: game.value.mapSize
    )

    switch game.value.state {
    case .isPlaying:
      return View.node()
    case .gameOver:
      return StackView.node(
        .init(
          Edges.equal(to: .parent),
          axis: .vertical,
          distribution: .fillEqually,
          spacing: 10.0
        ),
        Button.node(
          .init(onPress: Handler { game.set { $0 = restartedGameState } }),
          "Game over! Restart the game"
        )
      )
    case .initial:
      return StackView.node(
        .init(
          Edges.equal(to: .parent),
          axis: .vertical,
          distribution: .fillEqually,
          spacing: 10.0
        ),
        Button.node(
          .init(onPress: Handler { game.set { $0.state = .isPlaying } }),
          "Start the game"
        )
      )
    }
  }
}
