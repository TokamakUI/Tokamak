//
//  DatePicker.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 2/4/19.
//

import Foundation

public struct DatePicker: HostComponent {
  public struct Props: Equatable, ControlProps, StyleProps,
    ValueControlProps {
    public let handlers: EventHandlers
    public let style: Style?
    public let value: Date
    public let valueHandler: Handler<Date>?
    public let isEnabled: Bool
    public let isAnimated: Bool

    public init(
      _ style: Style? = nil,
      handlers: EventHandlers = [:],
      isAnimated: Bool = true,
      isEnabled: Bool = true,
      value: Date,
      valueHandler: Handler<Date>? = nil
    ) {
      self.handlers = handlers
      self.style = style
      self.value = value
      self.valueHandler = valueHandler
      self.isEnabled = isEnabled
      self.isAnimated = isAnimated
    }
  }

  public typealias Children = Null
}
