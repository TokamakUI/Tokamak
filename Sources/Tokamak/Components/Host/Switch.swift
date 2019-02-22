//
//  Switch.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 1/21/19.
//

public struct Switch: HostComponent {
  public struct Props: Equatable, ControlProps, StyleProps,
    ValueControlProps {
    public let handlers: EventHandlers
    public let style: Style?
    public let value: Bool
    public let valueHandler: Handler<Bool>?
    public let isEnabled: Bool
    public let isAnimated: Bool

    public init(
      _ style: Style? = nil,
      handlers: EventHandlers = [:],
      isAnimated: Bool = true,
      isEnabled: Bool = true,
      value: Bool,
      valueHandler: Handler<Bool>? = nil
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
