//
//  Counter.swift
//  TokamakDemo
//
//  Created by Max Desiatov on 14/02/2019.
//  Copyright © 2019 Max Desiatov. Tokamak is available under the Apache 2.0
//  license. See the LICENSE file for more info.
//

import Tokamak

struct Counter: LeafComponent {
  struct Props: Equatable {
    let countFrom: Int
  }

  static func render(props: Counter.Props, hooks: Hooks) -> AnyNode {
    let count = hooks.state(props.countFrom)

    return StackView.node(.init(
      Edges.equal(to: .safeArea),
      alignment: .center,
      axis: .vertical,
      distribution: .fillEqually
    ), [
      Button.node(
        .init(onPress: Handler { count.set { $0 + 1 } }),
        "Increment"
      ),

      Label.node(.init(alignment: .center), "\(count.value)"),
    ])
  }
}
