//
//  Controls.swift
//  Gluon_Example
//
//  Created by Max Desiatov on 14/02/2019.
//  Copyright © 2019 Gluon. All rights reserved.
//

import Gluon

struct Controls: LeafComponent {
  typealias Props = Null

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let sliding = hooks.state(0.5 as Float)
    let switchState = hooks.state(true)
    let stepperState = hooks.state(0.0)
    let isEnabled = hooks.state(true)

    let children = [
      StackView.node(
        .init(
          alignment: .center,
          axis: .horizontal,
          spacing: 10.0
        ), [
          Switch.node(
            .init(
              value: isEnabled.value,
              valueHandler: Handler(isEnabled.set)
            )
          ),

          Label.node(
            .init(alignment: .center),
            "isEnabled \(isEnabled.value)"
          ),
        ]
      ),

      Slider.node(.init(
        isEnabled: isEnabled.value,
        value: sliding.value,
        valueHandler: Handler(sliding.set),
        Style(Width.equal(to: .parent))
      )),

      Label.node(.init(alignment: .center), "\(sliding.value)"),

      StackView.node(
        .init(
          alignment: .center,
          axis: .horizontal,
          spacing: 10.0
        ), [
          Switch.node(
            .init(
              isEnabled: isEnabled.value,
              value: switchState.value,
              valueHandler: Handler(switchState.set)
            )
          ),

          Label.node(.init(alignment: .center), "\(switchState.value)"),
        ]
      ),

      StackView.node(
        .init(
          alignment: .center,
          axis: .horizontal,
          spacing: 10.0
        ), [
          Stepper.node(
            .init(
              isEnabled: isEnabled.value,
              value: stepperState.value,
              valueHandler: Handler(stepperState.set)
            )
          ),

          Label.node(.init(alignment: .center), "\(stepperState.value)"),
        ]
      ),
    ]

    return StackView.node(
      .init(
        alignment: .center,
        axis: .vertical,
        distribution: .fillEqually,
        Edges.equal(to: .safeArea)
      ),
      children
    )
  }
}
