//
//  Counter.swift
//  Tokamak_Example
//
//  Created by Max Desiatov on 14/02/2019.
//  Copyright © 2019 Max Desiatov. All rights reserved.
//

import Tokamak

struct Counter: LeafComponent {
  struct Props: Equatable {
    let countFrom: Int
  }

  static func render(props: Counter.Props, hooks: Hooks) -> AnyNode {
    let count = hooks.state(props.countFrom)

    return StackView.node(.init(
      alignment: .center,
      axis: .vertical,
      distribution: .fillEqually,
      Edges.equal(to: .safeArea)
    ), [
      Image.node(.init(named: "gluon")),
      Button.node(
        .init(onPress: Handler { count.set { $0 + 1 } }),
        "Increment"
      ),

      Label.node(.init(alignment: .center), "\(count.value)"),
    ])
  }
}
