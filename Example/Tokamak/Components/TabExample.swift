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
        if let index = oldList.firstIndex(of: id) {
          oldList.remove(at: index)
        }
        return oldList
      } else {
        return tabsIdToRemove.value
      }
    }

    let tabDictionary = [
      TabContent.node(.init(
        name: "first",
        clickHandler: Handler { tabsIdToRemove.set(removeTab(id: 0)) }
      )),
      TabContent.node(.init(
        name: "second",
        clickHandler: Handler { tabsIdToRemove.set(removeTab(id: 1)) }
      )),
      TabContent.node(.init(
        name: "third",
        clickHandler: Handler { tabsIdToRemove.set(removeTab(id: 2)) }
      )),
    ]

    let newTabList = Array(tabsIdToRemove.value.map { tabDictionary[$0] })

    return TabPresenter.node(
      .init(isAnimated: true, selectedIndex: selectedIndex),
      newTabList
    )
  }
}
