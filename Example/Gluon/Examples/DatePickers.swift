//
//  DatePicker.swift
//  Gluon_Example
//
//  Created by Max Desiatov on 14/02/2019.
//  Copyright © 2019 Gluon. All rights reserved.
//

import Gluon

struct DatePickers: LeafComponent {
  typealias Props = Null

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let currentDateTime = Date()
    let date = hooks.state(currentDateTime)
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    let formattedDate = dateFormatter.string(from: date.value)
    let labelProps = Label.Props(
      alignment: .center,
      lineBreakMode: .wordWrap,
      numberOfLines: 0
    )

    return StackView.node(.init(
      axis: .vertical,
      distribution: .fillEqually,
      Edges.equal(to: .parent)
    ), [
      Label.node(
        labelProps,
        "\(formattedDate)"
      ),
      Label.node(
        labelProps,
        "This picker doesn't animate state changes in the next picker"
      ),
      DatePicker.node(
        .init(
          value: date.value,
          valueHandler: Handler(date.set),
          Style(Width.equal(to: .parent))
        )
      ),
      Label.node(
        labelProps,
        "This picker animates state changes in the previous picker"
      ),
      DatePicker.node(
        .init(
          isAnimated: false,
          value: date.value,
          valueHandler: Handler(date.set),
          Style(Width.equal(to: .parent))
        )
      ),
    ])
  }
}
