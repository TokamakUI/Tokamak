//
//  Slider.swift
//  Gluon
//
//  Created by Max Desiatov on 29/12/2018.
//

public struct Slider: HostComponent {
  public struct Props: Equatable, ControlProps, StyleProps,
    ValueControlProps {
    public var isEnabled: Bool

    public let handlers: EventHandlers
    public let style: Style?
    public let value: Float
    public let valueHandler: Handler<Float>?

    public init(handlers: EventHandlers = [:],
                _ style: Style? = nil,
                value: Float,
                valueHandler: Handler<Float>? = nil,
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
