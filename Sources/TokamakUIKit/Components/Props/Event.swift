//
//  ActionTarget.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 04/12/2018.
//

import Tokamak
import UIKit

extension UIControl.Event {
  public init?(_ value: Event) {
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
    case .hoverEnter, .hoverExit, .contextualMenu:
      return nil
    }
  }
}
