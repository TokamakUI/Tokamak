//
//  Event.swift
//  Tokamak
//
//  Created by Max Desiatov on 04/12/2018.
//

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

  // FIXME: provisional stability, taken from Marzipan preview symbols
  // https://www.highcaffeinecontent.com/blog/20190302-Making-Marzipan-Apps-Sing
  case hoverEnter
  case hoverExit
  case contextualMenu
}

public typealias EventHandlers = [Event: Handler<()>]

public protocol ControlProps {
  var handlers: EventHandlers { get }
  var isEnabled: Bool { get }
}

public protocol ValueControlProps {
  associatedtype Value

  var value: Value { get }
  var valueHandler: Handler<Value>? { get }
}
