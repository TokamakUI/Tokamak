//
//  Throbber.swift
//  TokamakDemo-iOS
//
//  Created by Max Desiatov on 20/03/2019.
//  Copyright © 2019 Tokamak contributors. Tokamak is available under the
//  Apache 2.0 license. See the LICENSE file for more info.
//

import Tokamak

struct ThrobberExample: PureLeafComponent {
  typealias Props = Null

  static func render(props: Null) -> AnyNode {
    View.node(
      .init(Style(
        Edges.equal(to: .parent),
        backgroundColor: .black
      )),
      Throbber.node(.init(
        Style(Edges.equal(to: .parent)),
        isAnimating: true,
        variety: .whiteLarge
      ))
    )
  }
}
