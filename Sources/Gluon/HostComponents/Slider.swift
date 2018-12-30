//
//  Slider.swift
//  Gluon
//
//  Created by Max Desiatov on 29/12/2018.
//

public struct SliderProps: Equatable, EventHandlerProps, ValueControlProps {
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

public struct Slider: HostComponent {
  public typealias Props = SliderProps
  public typealias Children = Null
}
