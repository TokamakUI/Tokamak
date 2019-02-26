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
    let cellSize: Int
    let mapSizeInCells: Size
  }

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let game = hooks.state(
      Game(
        state: .initial,
        currentDirection: .up,
        snake: [Point(x: 10, y: 10), Point(x: 10, y: 11), Point(x: 10, y: 12)],
        target: Point(x: 0, y: 0),
        mapSize: Size(width: props.mapSizeInCells.width, height: props.mapSizeInCells.height), speed: 1
      )
    )
    let timer = hooks.ref(type: Timer.self)
    let interval = hooks.state(10.0)
    let isEnableVertivalMove = ![.up, .down].contains(game.value.currentDirection)
    let isEnableHorizontalMove = ![.left, .right].contains(game.value.currentDirection)

    hooks.finalizedEffect([AnyEquatable(game.value.state), AnyEquatable(interval.value)]) {
      guard game.value.state == .isPlaying else { return {} }

      timer.value = Timer.scheduledTimer(
        withTimeInterval: 1 / interval.value,
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
          Edges.equal(to: .parent),
          axis: .vertical,
          distribution: .fillEqually,
          spacing: 10.0
        ), [
          View.node(
            [
              View.node(
                .init(Style([Top.equal(to: .parent, constant: 10), Bottom.equal(to: .parent, constant: 30), Center.equal(to: .parent),
                             Width.equal(to: Double(props.cellSize) * game.value.mapSize.width + 10),
                             Height.equal(to: Double(props.cellSize) * game.value.mapSize.height - 30)], borderColor: .black, borderWidth: 2)),
                [
                  View.node(
                    Cell.node(.init(size: props.cellSize, location: game.value.target))
                  ),
                  View.node(
                    game.value.snake.map {
                      Cell.node(.init(size: props.cellSize, location: $0))
                    }
                  ),
                ]
              ),
            ]
          ),

          StackView.node(.init(
            axis: .vertical,
            distribution: .fillEqually
          ), [
            Button.node(
              .init(isEnabled: isEnableVertivalMove, onPress: Handler { game.set { $0.currentDirection = .up } }),
              "⬆️"
            ),
            StackView.node(.init(
              axis: .horizontal,
              distribution: .fillEqually
            ), [
              Button.node(
                .init(isEnabled: isEnableHorizontalMove, onPress: Handler { game.set { $0.currentDirection = .left } }),
                "⬅️"
              ),

              Button.node(
                .init(isEnabled: isEnableHorizontalMove, onPress: Handler { game.set { $0.currentDirection = .right } }),
                "➡️"
              ),
            ]),
            Button.node(
              .init(isEnabled: isEnableVertivalMove, onPress: Handler { game.set { $0.currentDirection = .down } }),
              "⬇️"
            ),
          ]),

          StackView.node(
            .init(
              alignment: .center,
              axis: .vertical,
              distribution: .fillEqually
            ),
            [
              Stepper.node(
                .init(
                  maximumValue: 100.0,
                  minimumValue: 1.0,
                  stepValue: 1.0,
                  value: interval.value,
                  valueHandler: Handler(interval.set)
                )
              ),
              Label.node(
                .init(alignment: .center),
                "\(interval.value)X"
              ),
            ]
          ),
        ]
      )
    default:
      return StackView.node(
        .init(
          Edges.equal(to: .parent),
          axis: .vertical,
          distribution: .fillEqually,
          spacing: 10.0
        ), [
          Button.node(
            .init(onPress: Handler { game.set { $0.state = .isPlaying } }),
            "Start the game"
          ),
        ]
      )
    }
  }
}
