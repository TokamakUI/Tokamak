//
//  Slider.swift
//  Tokamak
//
//  Created by Max Desiatov on 29/12/2018.
//

public struct Slider: HostComponent {
  public struct Props: Equatable, ControlProps, StyleProps,
    ValueControlProps {
    public let handlers: EventHandlers
    public let style: Style?
    public let value: Float
    public let valueHandler: Handler<Float>?
    public let isEnabled: Bool

    public init(
      _ style: Style? = nil,
      handlers: EventHandlers = [:],
      isEnabled: Bool = true,
      value: Float,
      valueHandler: Handler<Float>? = nil
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
