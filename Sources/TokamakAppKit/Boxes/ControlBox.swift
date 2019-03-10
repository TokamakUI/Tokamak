//
//  ControlBox.swift
//  TokamakAppKit
//
//  Created by Max Desiatov on 01/01/2019.
//

import AppKit
import Tokamak

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
class ControlBox<T: NSControl & Default>: ViewBox<T> {
  private var handlersMask: NSEvent.EventTypeMask = []
  private var handlers = [Event: Handler<()>]()
  private var action: Action!
  let delegate = TextEditingDelegate()

  override init(
    _ view: T,
    _ viewController: NSViewController,
    _ node: AnyNode
  ) {
    super.init(view, viewController, node)

    delegate.callback = { [weak self] in
      self?.handlers[$0]?.value(())
    }

    action = Action { [weak self] in
      guard let eventMask = NSApp.currentEvent?.associatedEventsMask,
        let event = Event(eventMask) else { return }

      self?.handlers[event]?.value(())
    }
    view.target = action
    view.action = actionSelector
  }

  func bind(handlers: [Event: Handler<()>]) {
    self.handlers = handlers
  }
}

/** Helper class that work around the fact that `ControlBox` isn't a subclass
 of `NSObject`, which is required by `NSControlTextEditingDelegate`
 */
class TextEditingDelegate: NSObject, NSControlTextEditingDelegate {
  fileprivate var callback: ((Event) -> ())?

  func controlTextDidBeginEditing(_: Notification) {
    callback?(.editingDidBegin)
  }

  func controlTextDidChange(_ obj: Notification) {
    callback?(.editingChanged)
  }

  func controlTextDidEndEditing(_ obj: Notification) {
    callback?(.editingDidEnd)
  }
}
