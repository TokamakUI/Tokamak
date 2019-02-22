//
//  Stepper.swift
//  Tokamak
//
//  Created by Matvii Hodovaniuk on 1/21/19.
//

public struct Stepper: HostComponent {
  public struct Props: Equatable, ControlProps, StyleProps,
    ValueControlProps {
    public let autorepeat: Bool
    public let handlers: EventHandlers
    public let isEnabled: Bool
    public let maximumValue: Double
    public let minimumValue: Double
    public let stepValue: Double
    public let value: Double
    public let valueHandler: Handler<Double>?
    public let wraps: Bool
    public let style: Style?

    public init(
      _ style: Style? = nil,
      autorepeat: Bool = true,
      handlers: EventHandlers = [:],
      isEnabled: Bool = true,
      maximumValue: Double = 100.0,
      minimumValue: Double = 0.0,
      stepValue: Double = 1.0,
      value: Double,
      valueHandler: Handler<Double>? = nil,
      wraps: Bool = false
    ) {
      self.autorepeat = autorepeat
      self.handlers = handlers
      self.isEnabled = isEnabled
      self.maximumValue = maximumValue
      self.minimumValue = minimumValue
      self.stepValue = stepValue
      self.value = value
      self.valueHandler = valueHandler
      self.wraps = wraps
      self.style = style
    }
  }

  public typealias Children = Null
}
