//
//  Gamepad.swift
//  TokamakDemo
//
//  Created by Matvii Hodovaniuk on 2/27/19.
//  Copyright © 2019 Tokamak. All rights reserved.
//

import Tokamak

struct Gamepad: PureLeafComponent {
  struct Props: Equatable {
    let game: State<Game>
  }

  static func render(props: Gamepad.Props) -> AnyNode {
    let game = props.game
    let isVerticalMoveEnabled = ![.up, .down]
      .contains(game.value.currentDirection)
    let isHorizontalMoveEnabled = ![.left, .right]
      .contains(game.value.currentDirection)

    return StackView.node(.init(
      axis: .vertical,
      distribution: .fillEqually
    ), [
      Button.node(
        .init(
          isEnabled: isVerticalMoveEnabled,
          onPress: Handler {
            game.set { $0.currentDirection = .up }
          }
        ),
        "⬆️"
      ),
      StackView.node(.init(
        axis: .horizontal,
        distribution: .fillEqually
      ), [
        Button.node(
          .init(
            isEnabled: isHorizontalMoveEnabled,
            onPress: Handler {
              game.set { $0.currentDirection = .left }
            }
          ),
          "⬅️"
        ),

        Button.node(
          .init(
            isEnabled: isHorizontalMoveEnabled,
            onPress: Handler {
              game.set { $0.currentDirection = .right }
            }
          ),
          "➡️"
        ),
      ]),
      Button.node(
        .init(
          isEnabled: isVerticalMoveEnabled,
          onPress: Handler { game.set { $0.currentDirection = .down } }
        ),
        "⬇️"
      ),
    ])
  }
}
