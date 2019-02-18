//
//  LayerProps.swift
//  Tokamak_Example
//
//  Created by Max Desiatov on 14/02/2019.
//  Copyright © 2019 Max Desiatov. All rights reserved.
//

import Tokamak

struct LayerProps: LeafComponent {
  typealias Props = Null

  static func render(props: Null, hooks: Hooks) -> AnyNode {
    let state = hooks.state(0.5 as Float)

    return
      StackView.node(.init(
        axis: .vertical,
        distribution: .fillEqually,
        Edges.equal(to: .safeArea)
      ), [
        Slider.node(.init(
          value: state.value,
          valueHandler: Handler(state.set),
          Style(Width.equal(to: .parent))
        )),

        View.node(
          .init(
            Style(
              backgroundColor: .red,
              borderWidth: Float(state.value * 10),
              cornerRadius: Float(state.value * 10),
              opacity: Float(state.value),
              Width.equal(to: .parent)
            )
          ),
          Label.node(.init(
            alignment: .center,
            textColor: .white,
            Style(
              [Top.equal(to: .parent, constant: Double(state.value) * 100),
               Left.equal(to: .parent, constant: Double(state.value) * 200)]
            )
          ), "\(state.value)")
        ),
      ])
  }
}
