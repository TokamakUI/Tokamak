//
//  Constraints.swift
//  Tokamak_Example
//
//  Created by Max Desiatov on 14/02/2019.
//  Copyright © 2019 Max Desiatov. All rights reserved.
//

import Tokamak
import TokamakUIKit

struct Constraints: LeafComponent {
  typealias Props = Null

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let left = hooks.state(0.5 as Float)
    let ref = hooks.ref(type: UIView.self)

    hooks.effect(Null()) {
      guard let view = ref.value else { return }
      UIView.animate(withDuration: 2) {
        view.backgroundColor = .green
      }
    }

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
        ref: ref,
        .init(Style(backgroundColor: .red)),
        Label.node(.init(
          Style(Left.equal(to: .parent, constant: Double(left.value) * 200)),
          alignment: .center,
          textColor: .white
        ), "\(left.value)")
      ),
    ])
  }
}
