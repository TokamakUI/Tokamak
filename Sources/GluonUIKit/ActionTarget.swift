//
//  ActionTarget.swift
//  Gluon
//
//  Created by Max Desiatov on 04/12/2018.
//

import Gluon
import UIKit

final class ActionTarget {
  private let handler: () -> ()

  init(_ handler: @escaping () -> ()) {
    self.handler = handler
  }

  @objc func perform() {
    handler()
  }
}

extension UIControl.Event {
  init(_ value: Event) {
    switch value {
    case .touchDown:
      self = .touchDown
    case .touchDownRepeat:
      self = .touchDownRepeat
    case .touchDragInside:
      self = .touchDragInside
    case .touchDragOutside:
      self = .touchDragOutside
    case .touchDragEnter:
      self = .touchDragEnter
    case .touchDragExit:
      self = .touchDragExit
    case .touchUpInside:
      self = .touchUpInside
    case .touchUpOutside:
      self = .touchUpOutside
    case .touchCancel:
      self = .touchCancel
    case .valueChanged:
      self = .valueChanged
    case .editingDidBegin:
      self = .editingDidBegin
    case .editingChanged:
      self = .editingChanged
    case .editingDidEnd:
      self = .editingDidEnd
    case .editingDidEndOnExit:
      self = .editingDidEndOnExit
    case .allTouchEvents:
      self = .allTouchEvents
    case .allEditingEvents:
      self = .allEditingEvents
    case .allEvents:
      self = .allEvents
    }
  }
}

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
