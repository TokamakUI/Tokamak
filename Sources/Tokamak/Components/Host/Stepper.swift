//
//  Stepper.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 1/21/19.
//

public struct Stepper: HostComponent {
  public struct Props: Equatable, ControlProps, StyleProps,
    ValueControlProps {
    public let handlers: EventHandlers
    public let style: Style?
    public let value: Double
    public let valueHandler: Handler<Double>?
    public let isEnabled: Bool

    public init(
      handlers: EventHandlers = [:],
      isEnabled: Bool = true,
      value: Double,
      valueHandler: Handler<Double>? = nil,
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
