//
//  ViewBox.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import Gluon
import UIKit

private final class Action {
  private let handler: () -> ()

  init(_ handler: @escaping () -> ()) {
    self.handler = handler
  }

  @objc func perform() {
    handler()
  }
}

private let actionSelector = #selector(Action.perform)

class ViewBox<T: UIView> {
  let view: T

  init(_ view: T) {
    self.view = view
  }
}

extension ViewBox: UITarget {}

/// Wraps Objective-C target/action pattern used by `UIControl` with a swifty
/// closure-based API.
class ControlBox<T: UIControl & Default>: ViewBox<T> {
  private var handlers = [Event: Action]()

  func bind(handlers: [Event: Handler<()>]) {
    for (e, h) in self.handlers {
      view.removeTarget(h, action: actionSelector, for: UIControl.Event(e))
    }
    self.handlers.removeAll()

    for (e, h) in handlers {
      let action = Action(h.value)
      view.addTarget(action, action: actionSelector, for: UIControl.Event(e))

      self.handlers[e] = action
    }
  }
}

protocol ValueStorage: class {
  associatedtype Value

  var value: Value { get set }
}

final class ValueControlBox<T: UIControl & Default & ValueStorage>:
  ControlBox<T> {
  private var valueChangedAction: Action?

  var value: T.Value {
    get {
      return view.value
    }
    set {
      view.value = newValue
    }
  }

  func bind(valueChangedHandler: Handler<T.Value>?) {
    if let existing = self.valueChangedAction {
      view.removeTarget(existing, action: actionSelector, for: .valueChanged)
      valueChangedAction = nil
    }

    if let handler = valueChangedHandler {
      // The closure is owned by the `view`, which is owned by `self`.
      let action = Action { [weak self] in
        guard let self = self else { return }
        handler.value(self.view.value)
      }

      view.addTarget(action, action: actionSelector, for: .valueChanged)
      valueChangedAction = action
    }
  }
}
