//
//  Timer.swift
//  Gluon_Example
//
//  Created by Max Desiatov on 17/02/2019.
//  Copyright © 2019 Gluon. All rights reserved.
//

import Foundation
import Gluon

struct TimerCounter: LeafComponent {
  typealias Props = Null

  static func render(props: Null, hooks: Hooks) -> AnyNode {
    let count = hooks.state(0)
    let timer = hooks.ref(type: Timer.self)

    hooks.effect(Null()) { () -> () -> () in
      timer.value = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
        count.set { $0 + 1 }
      }
      return {
        timer.value?.invalidate()
      }
    }

    return Label.node(.init(Style(Center.equal(to: .parent))), "\(count.value)")
  }
}
