//
//  ActionTarget.swift
//  TokamakAppKit
//
//  Created by Max Desiatov on 04/12/2018.
//

import AppKit
import Tokamak

extension NSEvent.EventTypeMask {
  public init?(_ value: Event) {
    switch value {
    case .touchDown:
      self = .leftMouseDown
    case .touchUpInside:
      self = .leftMouseUp
    case .touchDragInside:
      self = .leftMouseDragged
    //    case .touchDownRepeat:
    //        self = .touchDownRepeat
    //    case .touchDragOutside:
    //        self = .touchDragOutside
    //    case .touchDragEnter:
    //        self = .touchDragEnter
    //    case .touchDragExit:
    //        self = .touchDragExit
    //    case .touchUpOutside:
    //        self = .touchUpOutside
    //    case .touchCancel:
    //        self = .touchCancel
    //    case .valueChanged:
    //        self = .valueChanged
    //    case .editingDidBegin:
    //        self = .editingDidBegin
    //    case .editingChanged:
    //        self = .editingChanged
    //    case .editingDidEnd:
    //        self = .editingDidEnd
    //    case .editingDidEndOnExit:
    //        self = .editingDidEndOnExit
    //    case .allTouchEvents:
    //        self = .allTouchEvents
    //    case .allEditingEvents:
    //        self = .allEditingEvents
    case .hoverEnter:
      self = .mouseEntered
    case .hoverExit:
      self = .mouseExited
    case .allEvents:
      self = .any
    default:
      assertionFailure()
      return nil
    }
  }
}

extension Event {
  public init?(_ value: NSEvent.EventTypeMask) {
    switch value {
    //    case .touchDown:
    //      self = .leftMouseDown
    //    case .touchUpInside:
    //      self = .leftMouseUp
    //    case .touchDragInside:
    //      self = .leftMouseDragged
    //    case .touchDownRepeat:
    //        self = .touchDownRepeat
    //    case .touchDragOutside:
    //        self = .touchDragOutside
    //    case .touchDragEnter:
    //        self = .touchDragEnter
    //    case .touchDragExit:
    //        self = .touchDragExit
    //    case .touchUpOutside:
    //        self = .touchUpOutside
    //    case .touchCancel:
    //        self = .touchCancel
    //    case .valueChanged:
    //        self = .valueChanged
    //    case .editingDidBegin:
    //        self = .editingDidBegin
    //    case .editingChanged:
    //        self = .editingChanged
    //    case .editingDidEnd:
    //        self = .editingDidEnd
    //    case .editingDidEndOnExit:
    //        self = .editingDidEndOnExit
    //    case .allTouchEvents:
    //        self = .allTouchEvents
    //    case .allEditingEvents:
    //        self = .allEditingEvents
    //    case .hoverEnter:
    //      self = .mouseEntered
    //    case .hoverExit:
    //      self = .mouseExited
    //    case .allEvents:
    //      self = .any
    default:
      assertionFailure()
      return nil
    }
  }
}
