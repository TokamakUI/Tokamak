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
    let selectedIndex = hooks.state(0)
    let tabsIdToRemove = hooks.state("")
    var tabDictionary = [
      "First": TabItem.node(
        .init(title: "First"),
        StackView.node(.init(
          Edges.equal(to: .safeArea),
          alignment: .center,
          axis: .vertical,
          distribution: .fillEqually
        ), [
          Button.node(.init(
            onPress: Handler { tabsIdToRemove.set { _ in "First" } },
            text: "Remove first tab"
          )),
          Label.node(.init(alignment: .center, text: "First")),
        ])
      ),
      "Second": TabItem.node(
        .init(title: "Second"),
        StackView.node(.init(
          Edges.equal(to: .safeArea),
          alignment: .center,
          axis: .vertical,
          distribution: .fillEqually
        ), [
          Button.node(.init(
            onPress: Handler { tabsIdToRemove.set { _ in "Second" } },
            text: "Remove second tab"
          )),
          Label.node(.init(alignment: .center, text: "Second")),
        ])
      ),
      "Third": TabItem.node(
        .init(title: "Third"),
        StackView.node(.init(
          Edges.equal(to: .safeArea),
          alignment: .center,
          axis: .vertical,
          distribution: .fillEqually
        ), [
          Button.node(.init(
            onPress: Handler { tabsIdToRemove.set { _ in "Third" } },
            text: "Remove third tab"
          )),
          Label.node(.init(alignment: .center, text: "Third")),
        ])
      ),
    ]

    if tabsIdToRemove.value != "" {
      tabDictionary.removeValue(forKey: tabsIdToRemove.value)
    }

    let newTabList = Array(tabDictionary.values.map { $0 })

    return TabPresenter.node(
      .init(isAnimated: true, selectedIndex: selectedIndex),
      newTabList,
      ref: refTabBar
    )
  }
}
