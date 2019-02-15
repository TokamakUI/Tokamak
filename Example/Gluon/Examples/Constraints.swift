//
//  Constraints.swift
//  Gluon_Example
//
//  Created by Max Desiatov on 14/02/2019.
//  Copyright © 2019 Gluon. All rights reserved.
//

import Gluon

struct Constraints: LeafComponent {
  typealias Props = Null

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let left = hooks.state(0.5 as Float)

    return StackView.node(.init(
      axis: .vertical,
      distribution: .fillEqually,
      Edges.equal(to: .parent)
    ), [
      Slider.node(.init(
        value: left.value,
        valueHandler: Handler(left.set),
        Style(Width.equal(to: .parent))
      )),

      View.node(
        .init(Style(backgroundColor: .red)),
        Label.node(.init(
          alignment: .center,
          textColor: .white,
          Style(Left.equal(to: .parent, constant: Double(left.value) * 200))
        ), "\(left.value)")
      ),
    ])
  }
}
