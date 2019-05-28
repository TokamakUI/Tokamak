//
//  TextField.swift
//  TokamakDemo
//
//  Created by Matvii Hodovaniuk on 2/25/19.
//  Copyright © 2019 Tokamak. Tokamak is available under the Apache 2.0
//  license. See the LICENSE file for more info.
//

import Tokamak

struct OneRenderFunctionPositive: PureLeafCOmponent {
  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let textFieldStyle = Style(
      [
        Height.equal(to: 44),
        Width.equal(to: .parent),
      ]
    )

    return StackView.node(.init(
      [
        Leading.equal(to: .safeArea),
        Trailing.equal(to: .safeArea),
        Top.equal(to: .safeArea),
      ],
      alignment: .top,
      axis: .vertical
    ), [
      TextField.node(.init(
        textFieldStyle,
        placeholder: "Default",
        value: text.value,
        valueHandler: Handler(text.set)
      )),
    ])
  }
}

struct OneRenderFunctionPositiveAnotherOne: LeafCOmponent {
  static func render(props: Props) -> AnyNode {
    let textFieldStyle = Style(
      [
        Height.equal(to: 44),
        Width.equal(to: .parent),
      ]
    )

    return StackView.node(.init(
      [
        Leading.equal(to: .safeArea),
        Trailing.equal(to: .safeArea),
        Top.equal(to: .safeArea),
      ],
      alignment: .top,
      axis: .vertical
    ), [
      TextField.node(.init(
        textFieldStyle,
        placeholder: "Default",
        value: text.value,
        valueHandler: Handler(text.set)
      )),
    ])
  }
}
