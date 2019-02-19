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
      alignment: .center,
      axis: .vertical,
      distribution: .fillEqually,
      Edges.equal(to: .safeArea)
    ), [
      Image.node(.init(name: "tokamak", Style(contentMode: .scaleAspectFit))),
    ])
  }
}
