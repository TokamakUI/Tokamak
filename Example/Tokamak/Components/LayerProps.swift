//
//  LayerProps.swift
//  TokamakDemo
//
//  Created by Max Desiatov on 14/02/2019.
//  Copyright © 2019 Max Desiatov. Tokamak is available under the Apache 2.0
//  license. See the LICENSE file for more info.
//

import Tokamak

struct LayerProps: LeafComponent {
  typealias Props = Null

  static func render(props: Null, hooks: Hooks) -> AnyNode {
    let state = hooks.state(0.5 as Float)

    return
      StackView.node(.init(
        Edges.equal(to: .safeArea),
        axis: .vertical,
        distribution: .fillEqually
      ), [
        Slider.node(.init(
          Style(Width.equal(to: .parent)),
          value: state.value,
          valueHandler: Handler(state.set)
        )),

        View.node(
          .init(
            Style(
              Width.equal(to: .parent),
              backgroundColor: .red,
              borderWidth: Float(state.value * 10),
              cornerRadius: Float(state.value * 10),
              opacity: Float(state.value)
            )
          ),
          Label.node(.init(
            Style(
              [Top.equal(to: .parent, constant: Double(state.value) * 100),
               Left.equal(to: .parent, constant: Double(state.value) * 200)]
            ),
            alignment: .center,
            textColor: .white
          ), "\(state.value)")
        ),
      ])
  }
}
