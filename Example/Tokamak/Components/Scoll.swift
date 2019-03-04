//
//  Scoll.swift
//  TokamakDemo
//
//  Created by Matvii Hodovaniuk on 2/28/19.
//  Copyright © 2019 Tokamak. All rights reserved.
//

import Tokamak

struct ScrollViewExample: LeafComponent {
  typealias Props = Null

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let ref = hooks.ref(type: UIScrollView.self)
    var labels: [AnyNode] = []
    for i in 1 ..< 100 {
      labels.append(Label.node(.init(alignment: .center), "Text \(i)"))
    }
    return View.node(
      .init(
        Style(
          [
            Width.equal(to: .parent),
            Height.equal(to: .parent),
            CenterX.equal(to: .parent),
            ]
        )
      ),
      ScrollView.node(
        ref: ref,
        .init(
          Style(
            [
              Width.equal(to: .parent),
              Height.equal(to: .parent),
              CenterX.equal(to: .parent),
            ]
          )
        ),
        StackView.node(
          .init([
            Width.equal(to: .parent),
            Height.equal(to: .parent),
            CenterX.equal(to: .parent),
          ],
          axis: .vertical
          ),
          labels
        )
      )
    )
  }
}
