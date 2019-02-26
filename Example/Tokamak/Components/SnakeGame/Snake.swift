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
        state: .isPlaying,
        currentDirection: .up,
        snake: [Point(x: 10, y: 10), Point(x: 11, y: 11)],
        target: Point(x: 15, y: 15),
        mapSize: Size(width: 30, height: 30)
      )
    )
    let timer = hooks.ref(type: Timer.self)

    hooks.finalizedEffect(game.value.state) {
      guard game.value.state == .isPlaying else { return {} }

      timer.value = Timer.scheduledTimer(
        withTimeInterval: 1,
        repeats: true
      ) { _ in
        game.set { $0.tick() }
      }
      return {
        timer.value?.invalidate()
      }
    }

    return  StackView.node(
      .init(
        alignment: .center,
        axis: .horizontal,
        spacing: 10.0
      ),[
        View.node(
        [
          View.node(
            Cell.node(.init(size: props.cellSize, location: game.value.target))
          ),
          View.node(
            game.value.snake.map {
              Cell.node(.init(size: props.cellSize, location: $0))
            }
          ),
          ]),
        
        Button.node(
          .init(onPress: Handler { game.set { $0.currentDirection = .up } }),
          "⬆️ UP"
        ),
//        Button.node(
//          .init(onPress: Handler { game.set { $0.currentDirection = .right } }),
//          "➡️"
//        ),
//        Button.node(
//          .init(onPress: Handler { game.set { $0.currentDirection = .down } }),
//          "⬇️"
//        ),
//        Button.node(
//          .init(onPress: Handler { game.set { $0.currentDirection = .left } }),
//          "⬅️"
//        ),
      ]
    )
  }
}
