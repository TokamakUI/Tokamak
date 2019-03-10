//
//  ControlBox.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 01/01/2019.
//

import Tokamak
import UIKit

final class Action {
  private let handler: (()) -> ()

  init(_ handler: @escaping (()) -> ()) {
    self.handler = handler
  }

  @objc func perform() {
    handler(())
  }
}

let actionSelector = #selector(Action.perform)

/// Wraps Objective-C target/action pattern used by `UIControl` with a swifty
/// closure-based API.
class ControlBox<T: UIControl & Default>: ViewBox<T> {
  private var handlers = [Event: Action]()

  func bind(handlers: [Event: Handler<()>]) {
    for (e, h) in self.handlers {
      guard let event = UIControl.Event(e) else { continue }
      view.removeTarget(h, action: actionSelector, for: event)
    }
    self.handlers.removeAll()

    for (e, h) in handlers {
      guard let event = UIControl.Event(e) else { continue }

      let action = Action(h.value)
      view.addTarget(action, action: actionSelector, for: event)

      self.handlers[e] = action
    }
  }
}
