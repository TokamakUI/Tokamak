//
//  Animation.swift
//  TokamakDemo
//
//  Created by Max Desiatov on 25/02/2019.
//  Copyright © 2019 Tokamak. All rights reserved.
//

import Tokamak

struct Animation: CompositeComponent {
  private static let colors: [(Color, String)] = [
    (.white, "white"),
    (.red, "red"),
    (.green, "green"),
    (.blue, "blue"),
  ]

  typealias Props = Null
  typealias Children = [AnyNode]

  static func render(props: Null, children: Children, hooks: Hooks) -> AnyNode {
    let previousColor = hooks.state(0)
    let currentColor = hooks.state(0)
    let ref = hooks.ref(type: UIView.self)

    hooks.effect(currentColor.value) {
      guard let view = ref.value else { return }

      guard currentColor.value != previousColor.value else {
        view.backgroundColor = UIColor(colors[currentColor.value].0)
        return
      }

      UIView.animate(withDuration: 0.5, animations: {
        view.backgroundColor = UIColor(colors[currentColor.value].0)
      }, completion: { _ in
        previousColor.set(currentColor.value)
      })
    }

    return View.node(
      .init(Style(
        Edges.equal(to: .parent),
        backgroundColor: .white
      )),
      StackView.node(.init(
        Edges.equal(to: .safeArea),
        axis: .vertical,
        distribution: .fillEqually
      ), [
        View.node(.init(), children, ref: ref),
        SegmentedControl.node(
          .init(
            value: currentColor.value,
            valueHandler: Handler {
              // sometimes UISegmentedControl allows deselecting all segments
              guard $0 >= 0 else { return }
              currentColor.set($0)
            }
          ),
          colors.map { $0.1 }
        ),
      ])
    )
  }
}
