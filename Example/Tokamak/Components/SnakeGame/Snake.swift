//
//  Snake.swift
//  TokamakDemo
//
//  Created by Matvii Hodovaniuk on 2/25/19.
//  Copyright © 2019 Tokamak. Tokamak is available under the Apache 2.0
//  license. See the LICENSE file for more info.
//

import Tokamak

struct Snake: LeafComponent {
  struct Props: Equatable {
    let cellSize: Double
    let mapSizeInCells: Size
  }

  static func render(props: Props, hooks: Hooks) -> AnyNode {
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

          Gamepad.node(
            .init(game: game),
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
              Label.node(.init(
                alignment: .center,
                text: "\(speed.value)X"
              )),
            ]
          ),
        ]
      )
    case .gameOver, .initial:
      return GameMenu.node(.init(game: game))
    }
  }
}
