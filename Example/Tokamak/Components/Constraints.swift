//
//  Constraints.swift
//  Tokamak_Example
//
//  Created by Max Desiatov on 14/02/2019.
//  Copyright © 2019 Max Desiatov. Tokamak is available under the Apache 2.0
//  license. See the LICENSE file for more info.
//

import Tokamak

struct Constraints: LeafComponent {
  typealias Props = Null

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let left = hooks.state(0.5 as Float)

    return StackView.node(.init(
      Edges.equal(to: .safeArea),
      axis: .vertical,
      distribution: .fillEqually
    ), [
      Slider.node(.init(
        Style(Width.equal(to: .parent)),
        value: left.value,
        valueHandler: Handler(left.set)
      )),

      View.node(
        .init(Style(backgroundColor: .red)),
        Label.node(.init(
          Style(Left.equal(to: .parent, constant: Double(left.value) * 200)),
          alignment: .center,
          text: "\(left.value)",
          textColor: .white
        ))
      ),
    ])
  }
}
