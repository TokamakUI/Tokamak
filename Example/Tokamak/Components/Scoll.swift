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
    return ScrollView.node(.init(
      [
        Leading.equal(to: .safeArea),
        Trailing.equal(to: .safeArea),
        Top.equal(to: .safeArea),
      ]
    ), [
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
      Label.node(.init(alignment: .center), "Text"),
    ])
  }
}
