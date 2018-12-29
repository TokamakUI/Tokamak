//
//  ControlWrapper.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import Gluon
import UIKit

private let action = #selector(ActionTarget.perform)

/// Wraps Objective-C target/action pattern used by `UIControl` with swifty API
public struct ControlWrapper<T: UIControl> {
  let value: T
  private var targets = [Event: ActionTarget]()

  init(_ value: T) {
    self.value = value
  }

  mutating func bind(to event: Event, handler: @escaping () -> ()) {
    if let target = targets[event] {
      value.removeTarget(target,
                         action: action,
                         for: UIControl.Event(event))
    }

    let target = ActionTarget(handler)
    value.addTarget(target, action: action, for: UIControl.Event(event))

    targets[event] = target
  }
}

extension ControlWrapper: UIKitTarget {}
