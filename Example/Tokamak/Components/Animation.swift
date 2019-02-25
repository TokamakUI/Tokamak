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
    let backgroundColor = hooks.state(0)
    let ref = hooks.ref(type: UIView.self)

    hooks.effect(backgroundColor.value) {
      guard let view = ref.value else { return }

      guard backgroundColor.value != previousColor.value else {
        view.backgroundColor = UIColor(colors[backgroundColor.value].0)
        return
      }

      UIView.animate(withDuration: 0.5, animations: {
        view.backgroundColor = UIColor(colors[backgroundColor.value].0)
      }, completion: { _ in
        previousColor.set(backgroundColor.value)
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
        View.node(ref: ref, .init(), children),
        SegmentedControl.node(
          .init(value: backgroundColor.value,
                valueHandler: Handler {
                  guard $0 >= 0 else { return }
                  backgroundColor.set($0)
          }),
          colors.map { $0.1 }
        ),
      ])
    )
  }
}
