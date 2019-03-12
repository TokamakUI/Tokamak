//
//  Gamepad.swift
//  TokamakDemo
//
//  Created by Matvii Hodovaniuk on 2/27/19.
//  Copyright © 2019 Tokamak. Tokamak is available under the Apache 2.0
//  license. See the LICENSE file for more info.
//

import Tokamak

struct Gamepad: PureComponent {
  struct Props: Equatable {
    let game: State<Game>
  }

  typealias Children = [AnyNode]

  static func render(props: Props, children: Children) -> AnyNode {
    let game = props.game
    let isVerticalMoveEnabled = ![.up, .down]
      .contains(game.value.currentDirection)
    let isHorizontalMoveEnabled = ![.left, .right]
      .contains(game.value.currentDirection)

    return StackView.node(.init(
      alignment: .center,
      axis: .vertical,
      distribution: .fillEqually
    ), [
      Button.node(
        .init(
          Style(Width.equal(to: .parent, multiplier: 0.5)),
          isEnabled: isVerticalMoveEnabled,
          onPress: Handler {
            game.set { $0.currentDirection = .up }
          },
          text: "⬆️"
        )
      ),
      StackView.node(.init(
        [Width.equal(to: .parent)],
        axis: .horizontal,
        distribution: .fillEqually
      ), [
        Button.node(
          .init(
            isEnabled: isHorizontalMoveEnabled,
            onPress: Handler {
              game.set { $0.currentDirection = .left }
            },
            text: "⬅️"
          )
        ),

        Button.node(
          .init(
            isEnabled: isHorizontalMoveEnabled,
            onPress: Handler {
              game.set { $0.currentDirection = .right }
            },
            text: "➡️"
          )
        ),
      ]),
      Button.node(
        .init(
          Style(Width.equal(to: .parent, multiplier: 0.5)),
          isEnabled: isVerticalMoveEnabled,
          onPress: Handler { game.set { $0.currentDirection = .down } }
        )
      ),
    ] + children)
  }
}
