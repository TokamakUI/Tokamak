//
//  TabContent.swift
//  TokamakDemo-iOS
//
//  Created by Matvii Hodovaniuk on 3/25/19.
//  Copyright © 2019 Tokamak contributors. Tokamak is available under the
//  Apache 2.0 license. See the LICENSE file for more info.
//

import Tokamak

struct TabContent: LeafComponent {
  struct Props: Equatable {
    let name: String
    let clickHandler: Handler<()>
  }

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let stackViewStyle = StackView.Props(
      Edges.equal(to: .safeArea),
      alignment: .center,
      axis: .vertical,
      distribution: .fillEqually
    )
    return TabItem.node(
      .init(title: props.name),
      StackView.node(
        stackViewStyle,
        [
          Button.node(.init(
            onPress: props.clickHandler,
            text: "Remove \(props.name) tab"
          )),
          Label.node(.init(alignment: .center, text: props.name.uppercased())),
        ]
      )
    )
  }
}
