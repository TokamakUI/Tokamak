//
//  DatePicker.swift
//  Gluon
//
//  Created by Matvii Hodovaniuk on 2/4/19.
//

public struct DatePicker: HostComponent {
  public struct Props: Equatable, ControlProps, StyleProps,
    ValueControlProps {
    public let handlers: EventHandlers
    public let style: Style?
    public let value: Date
    public let valueHandler: Handler<Date>?
    public let isEnabled: Bool

    public init(
      handlers: EventHandlers = [:],
      isEnabled: Bool = true,
      value: Date,
      valueHandler: Handler<Date>? = nil,
      _ style: Style? = nil
    ) {
      self.handlers = handlers
      self.style = style
      self.value = value
      self.valueHandler = valueHandler
      self.isEnabled = isEnabled
    }
  }

  public typealias Children = Null
}
