//
//  Switch.swift
//  Gluon
//
//  Created by Matvii Hodovaniuk on 1/21/19.
//

public struct Switch: HostComponent {
  public struct Props: Equatable, EventHandlerProps, StyleProps,
    ValueControlProps {
    public let handlers: EventHandlers
    public let style: Style?
    public let value: Bool
    public let valueHandler: Handler<Bool>?

    public init(handlers: EventHandlers = [:],
                _ style: Style? = nil,
                value: Bool,
                valueHandler: Handler<Bool>? = nil) {
      self.handlers = handlers
      self.style = style
      self.value = value
      self.valueHandler = valueHandler
    }
  }

  public typealias Children = Null
}
