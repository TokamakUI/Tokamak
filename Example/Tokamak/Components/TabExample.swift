//
//  TabExample.swift
//  TokamakDemo-iOS
//
//  Created by Matvii Hodovaniuk on 3/13/19.
//  Copyright © 2019 Tokamak contributors. Tokamak is available under the Apache 2.0
//  license. See the LICENSE file for more info.
//

import Tokamak

struct TabExample: PureLeafComponent {
  typealias Props = Null

  static func render(props: Props) -> AnyNode {
    let tabProps = TabController.Props(isAnimated: true)
    return TabController.node(
      tabProps,
      [Label.node("First")]
    )
  }
}
