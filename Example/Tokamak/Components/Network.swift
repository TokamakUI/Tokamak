//
//  Network.swift
//  TokamakDemo-iOS
//
//  Created by Max Desiatov on 21/03/2019.
//  Copyright © 2019 Tokamak contributors. Tokamak is available under the
//  Apache 2.0 license. See the LICENSE file for more info.
//

import Tokamak

struct Network: LeafComponent {
  typealias Props = Null

  static func render(props: Null, hooks: Hooks) -> AnyNode {
    return Throbber.node(
      .init(
        Style(Edges.equal(to: .parent)),
        isAnimating: true
      ),
      Label.node("blah")
    )
  }
}
