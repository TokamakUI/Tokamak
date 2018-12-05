//
//  Event.swift
//  Gluon
//
//  Created by Max Desiatov on 04/12/2018.
//

import UIKit

public enum Event: CaseIterable, Hashable {
  case touchDown
  case touchDownRepeat
  case touchDragInside
  case touchDragOutside
  case touchDragEnter
  case touchDragExit
  case touchUpInside
  case touchUpOutside
  case touchCancel
  case valueChanged
  case editingDidBegin
  case editingChanged
  case editingDidEnd
  case editingDidEndOnExit
  case allTouchEvents
  case allEditingEvents
  case allEvents
}

public protocol EventHandlerProps {
  var handlers: [Event: Handler<()>] { get }
}
