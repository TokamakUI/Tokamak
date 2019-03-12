//
//  DatePicker.swift
//  TokamakDemo
//
//  Created by Max Desiatov on 14/02/2019.
//  Copyright © 2019 Max Desiatov. Tokamak is available under the Apache 2.0
//  license. See the LICENSE file for more info.
//

import Tokamak

struct DatePickers: LeafComponent {
  typealias Props = Null

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let currentDateTime = Date()
    let date = hooks.state(currentDateTime)
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    let formattedDate = dateFormatter.string(from: date.value)

    return StackView.node(.init(
      Edges.equal(to: .safeArea),
      axis: .vertical,
      distribution: .fillEqually
    ), [
      Label.node(.init(
        alignment: .center,
        lineBreakMode: .wordWrap,
        numberOfLines: 0,
        text: "\(formattedDate)"
      )),
      Label.node(.init(
        alignment: .center,
        lineBreakMode: .wordWrap,
        numberOfLines: 0,
        text: "This picker doesn't animate state changes in the next picker:"
      )),
      DatePicker.node(
        .init(
          Style(Width.equal(to: .parent)),
          value: date.value,
          valueHandler: Handler(date.set)
        )
      ),
      Label.node(.init(
        alignment: .center,
        lineBreakMode: .wordWrap,
        numberOfLines: 0,
        text: "This picker animates state changes in the previous picker:"
      )),
      DatePicker.node(
        .init(
          Style(Width.equal(to: .parent)),
          isAnimated: false,
          value: date.value,
          valueHandler: Handler(date.set)
        )
      ),
    ])
  }
}
