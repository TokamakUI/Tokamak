//
//  TabExample.swift
//  TokamakDemo-iOS
//
//  Created by Matvii Hodovaniuk on 3/13/19.
//  Copyright © 2019 Tokamak contributors. Tokamak is available under
//  the Apache 2.0
//  license. See the LICENSE file for more info.
//

import Tokamak

struct TabExample: LeafComponent {
  typealias Props = Null

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    let refTabBar = hooks.ref(type: UITabBarController.self)
    let style = Style(Center.equal(to: .parent))
    let selectedIndex = hooks.state(0)
    let tabsCount = hooks.state(3)
    let tabsList = [
      TabItem.node(
        .init(title: "First"),
        StackView.node(.init(
          Edges.equal(to: .safeArea),
          alignment: .center,
          axis: .vertical,
          distribution: .fillEqually
        ), [
          Button.node(.init(
            onPress: Handler { tabsCount.set { $0 - 1 } },
            text: "Increment"
          )),

          Label.node(.init(alignment: .center, text: "First")),
        ])
      ),
      TabItem.node(
        .init(title: "Second"),
        Label.node(.init(style, text: "Second"))
      ),
      TabItem.node(
        .init(title: "Third"),
        Label.node(.init(style, text: "Third"))
      ),
    ]
    var newTabList = tabsList
    if tabsCount.value >= 1 {
      newTabList = Array(tabsList[0..<tabsCount.value])
    } else {
      newTabList = tabsList
    }

    print(tabsCount.value)
    return TabPresenter.node(
      .init(isAnimated: true, selectedIndex: selectedIndex),
      newTabList,
      ref: refTabBar
    )
  }
}
