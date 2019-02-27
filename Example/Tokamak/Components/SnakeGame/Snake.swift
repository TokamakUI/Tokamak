//
//  Snake.swift
//  TokamakDemo
//
//  Created by Matvii Hodovaniuk on 2/25/19.
//  Copyright © 2019 Tokamak. All rights reserved.
//

import Tokamak

let initialSnake = [
  Point(x: 10.0, y: 10.0),
  Point(x: 10.0, y: 11.0),
  Point(x: 10.0, y: 12.0),
]
let initialTarget = Point(x: 0.0, y: 1.0)
let initialDirection = Game.Direction.up

struct Snake: LeafComponent {
  struct Props: Equatable {
    let cellSize: Double
    let mapSizeInCells: Size
  }

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let restartedGameState = Game(
      state: .isPlaying,
      currentDirection: initialDirection,
      snake: initialSnake,
      target: initialTarget,
      mapSize: Size(
        width: props.mapSizeInCells.width,
        height: props.mapSizeInCells.height
      )
    )

    let game = hooks.state(
      Game(
        state: .initial,
        currentDirection: initialDirection,
        snake: initialSnake,
        target: initialTarget,
        mapSize: Size(
          width: props.mapSizeInCells.width,
          height: props.mapSizeInCells.height
        )
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

      let style = Style(
        [
          Center.equal(to: .parent),
          Width.equal(
            to: Double(props.cellSize) * game.value.mapSize.width
          ),
          Height.equal(
            to: Double(props.cellSize) * game.value.mapSize.height
          ),
        ],
        borderColor: .black,
        borderWidth: 2
      )

      let stepperProps = Stepper.Props(maximumValue: 100.0,
                                       minimumValue: 1.0,
                                       stepValue: 1.0,
                                       value: speed.value,
                                       valueHandler: Handler(speed.set))
      
      let labelProps = Label.Props(alignment: .center)

      return StackView.node(
        .init(
          Edges.equal(to: .safeArea),
          axis: .vertical,
          distribution: .fillEqually,
          spacing: 10.0
        ), [
          View.node(
            [
              View.node(
                .init(style),
                [
                  View.node(
                    Cell.node(.init(
                      color: .red,
                      size: props.cellSize,
                      location: game.value.target
                    ))
                  ),
                  View.node(
                    game.value.snake.map { (location) -> AnyNode in
                      let props = Cell.Props(
                        color: .black,
                        size: props.cellSize,
                        location: location
                      )
                      return Cell.node(props)
                    }
                  ),
                ]
              ),
            ]
          ),

          Gamepad.node(.init(game: game)),

          [
            Stepper.node(
              stepperProps),
            Label.node(
              labelProps,
              "\(speed.value)X"
            ),
          ],
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
