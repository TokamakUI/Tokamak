//
//  TextField.swift
//  TokamakDemo
//
//  Created by Matvii Hodovaniuk on 2/25/19.
//  Copyright © 2019 Tokamak. Tokamak is available under the Apache 2.0
//  license. See the LICENSE file for more info.
//

import Tokamak

struct TextFieldExample: LeafComponent {
  typealias Props = Null

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let text = hooks.state("")
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
      TextField.node(.init(
        textFieldStyle,
        isEnabled: false,
        placeholder: "Disabled",
        value: text.value,
        valueHandler: Handler(text.set)
      )),
      TextField.node(.init(
        textFieldStyle,
        keyboardAppearance: .dark,
        placeholder: "Dark",
        value: text.value,
        valueHandler: Handler(text.set)
      )),
      TextField.node(.init(
        textFieldStyle,
        isSecureTextEntry: true,
        placeholder: "Password",
        value: text.value,
        valueHandler: Handler(text.set)
      )),
    ])
  }
}
