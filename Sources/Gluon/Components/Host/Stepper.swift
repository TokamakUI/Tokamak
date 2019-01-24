//
//  Stepper.swift
//  Gluon
//
//  Created by Matvii Hodovaniuk on 1/21/19.
//

public struct Stepper: HostComponent {
  public struct Props: Equatable, ControlProps, StyleProps,
    ValueControlProps {
    public var isEnabled: Bool

    public let handlers: EventHandlers
    public let style: Style?
    public let value: Double
    public let valueHandler: Handler<Double>?

    public init(handlers: EventHandlers = [:],
                _ style: Style? = nil,
                value: Double,
                valueHandler: Handler<Double>? = nil,
                isEnabled: Bool = true) {
      self.handlers = handlers
      self.style = style
      self.value = value
      self.valueHandler = valueHandler
      self.isEnabled = isEnabled
    }
  }

  public typealias Children = Null
}
