//
//  Slider.swift
//  Gluon
//
//  Created by Max Desiatov on 29/12/2018.
//

public struct Slider: HostComponent {
  public struct Props: Equatable, EventHandlerProps, ValueControlProps {
    public let handlers: EventHandlers
    public let value: Float
    public let valueHandler: Handler<Float>?

    public init(handlers: EventHandlers = [:],
                value: Float,
                valueHandler: Handler<Float>? = nil) {
      self.handlers = handlers
      self.value = value
      self.valueHandler = valueHandler
    }
  }

  public typealias Children = Null
}
