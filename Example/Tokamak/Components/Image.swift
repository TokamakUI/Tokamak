//
//  Image.swift
//  TokamakDemo
//
//  Created by Matvii Hodovaniuk on 2/18/19.
//  Copyright © 2019 Tokamak. All rights reserved.
//

import Tokamak

struct ImageExample: LeafComponent {
  typealias Props = Null

  static func render(props: Null, hooks: Hooks) -> AnyNode {
    return StackView.node(.init(
      alignment: .center,
      axis: .vertical,
      distribution: .fillEqually,
      Edges.equal(to: .safeArea)
    ), [
      Image.node(.init(name: "tokamak")),
    ])
  }
}
