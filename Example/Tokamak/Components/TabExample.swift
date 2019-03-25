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
    let selectedIndex = hooks.state(0)
    let tabsIdToRemove = hooks.state([0, 1, 2])
    let stackViewStyle = StackView.Props(
      Edges.equal(to: .safeArea),
      alignment: .center,
      axis: .vertical,
      distribution: .fillEqually
    )

    func removeTab(id: Int) -> [Int] {
      if tabsIdToRemove.value.count > 1 {
        var oldList = tabsIdToRemove.value
        oldList.remove(at: id)
        return oldList
      } else {
        return tabsIdToRemove.value
      }
    }

    var tabDictionary = [
      TabItem.node(
        .init(title: "First"),
        TabContent.node(.init(
          name: "first",
          id: 0,
          clickHandler: Handler { tabsIdToRemove.set(removeTab(id: 0)) }
        ))
      ),
      TabItem.node(
        .init(title: "Second"),
        StackView.node(
          stackViewStyle,
          [
            Button.node(.init(
              onPress: Handler { tabsIdToRemove.set(removeTab(id: 1)) },
              text: "Remove second tab"
            )),
            Label.node(.init(alignment: .center, text: "Second")),
          ]
        )
      ),
      TabItem.node(
        .init(title: "Third"),
        StackView.node(
          stackViewStyle,
          [
            Button.node(.init(
              onPress: Handler { tabsIdToRemove.set(removeTab(id: 2)) },
              text: "Remove third tab"
            )),
            Label.node(.init(alignment: .center, text: "Third")),
          ]
        )
      ),
    ]

    let newTabList = Array(tabsIdToRemove.value.map { tabDictionary[$0] })

    return TabPresenter.node(
      .init(isAnimated: true, selectedIndex: selectedIndex),
      newTabList
    )
  }
}
