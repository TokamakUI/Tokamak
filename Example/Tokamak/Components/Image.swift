//
//  Image.swift
//  TokamakDemo
//
//  Created by Matvii Hodovaniuk on 2/18/19.
//  Copyright © 2019 Tokamak. All rights reserved.
//

import Tokamak

struct ImageExample: PureLeafComponent {
  typealias Props = Null

  static func render(props _: Null) -> AnyNode {
    return StackView.node(.init(
      Edges.equal(to: .safeArea),
      alignment: .center,
      axis: .vertical,
      distribution: .fillEqually
    ), [
      Image.node(.init(
        Style(contentMode: .scaleAspectFit),
        name: "tokamak"
      )),
    ])
  }
}
