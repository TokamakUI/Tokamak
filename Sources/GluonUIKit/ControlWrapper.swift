//
//  ControlWrapper.swift
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

/// Wraps Objective-C target/action pattern used by `UIControl` with a swifty
/// closure-based API.
public class ControlWrapper<T: UIControl> {
  fileprivate(set) var control: T
  private var handlers = [Event: Action]()

  init(_ control: T) {
    self.control = control
  }

  func bind(handlers: [Event: Handler<()>]) {
    for (e, h) in self.handlers {
      control.removeTarget(h, action: actionSelector, for: UIControl.Event(e))
    }
    self.handlers.removeAll()

    for (e, h) in handlers {
      let action = Action(h.value)
      control.addTarget(action, action: actionSelector, for: UIControl.Event(e))

      self.handlers[e] = action
    }
  }
}

public protocol ValueStorage {
  associatedtype Value

  var value: Value { get set }
}

public final class ValueControlWrapper<T: UIControl & ValueStorage>:
  ControlWrapper<T> {
  private var valueChangedAction: Action?

  var value: T.Value {
    get {
      return control.value
    }
    set {
      control.value = newValue
    }
  }

  func bind(valueChangedHandler: Handler<T.Value>?) {
    if let existing = self.valueChangedAction {
      control.removeTarget(existing, action: actionSelector, for: .valueChanged)
    }

    if let handler = valueChangedHandler {
      let action = Action { [weak self] in
        guard let self = self else { return }
        handler.value(self.control.value)
      }
      control.addTarget(action, action: actionSelector, for: .valueChanged)
    }
  }
}

extension ControlWrapper: UIKitTarget {}
