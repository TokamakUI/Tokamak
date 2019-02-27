//
//  Snake.swift
//  TokamakDemo
//
//  Created by Matvii Hodovaniuk on 2/25/19.
//  Copyright © 2019 Tokamak. All rights reserved.
//

import Tokamak

struct Snake: LeafComponent {
  struct Props: Equatable {
    let cellSize: Double
    let mapSizeInCells: Size
  }

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let restartedGameState = Game(
      state: .isPlaying,
      mapSize: props.mapSizeInCells
    )

    let game = hooks.state(
      Game(
        mapSize: props.mapSizeInCells
      )
    )
    let timer = hooks.ref(type: Timer.self)
    let speed = hooks.state(10.0)

    hooks.finalizedEffect([
      AnyEquatable(game.value.state),
      AnyEquatable(speed.value),
    ]) {
      guard game.value.state == .isPlaying else { return {} }

      timer.value = Timer.scheduledTimer(
        withTimeInterval: 1 / speed.value,
        repeats: true
      ) { _ in
        game.set { $0.tick() }
      }
      return {
        timer.value?.invalidate()
      }
    }

    switch game.value.state {
    case .isPlaying:
      return StackView.node(
        .init(
          Edges.equal(to: .safeArea),
          axis: .vertical,
          distribution: .fillEqually,
          spacing: 10.0
        ), [
          Gameboard.node(.init(game: game, cellSize: props.cellSize)),

          Gamepad.node(.init(game: game),
                       
                       [
                         Stepper.node(
                           .init(
                             maximumValue: 100.0,
                             minimumValue: 1.0,
                             stepValue: 1.0,
                             value: speed.value,
                             valueHandler: Handler(speed.set)
                           )
                         ),
                         Label.node(
                           .init(alignment: .center),
                           "\(speed.value)X"
                         ),
          ]),
        ]
      )
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
