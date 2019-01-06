//
//  SegmentedControl.swift
//  Gluon
//
//  Created by Max Desiatov on 05/01/2019.
//

public struct SegmentedControl: HostComponent {
  public struct Props: Equatable, EventHandlerProps, StyleProps,
    ValueControlProps {
    public let handlers: EventHandlers
    public let style: Style?
    public let value: Int
    public let valueHandler: Handler<Int>?

    public init(handlers: EventHandlers = [:],
                _ style: Style? = nil,
                value: Int,
                valueHandler: Handler<Int>? = nil) {
      self.handlers = handlers
      self.style = style
      self.value = value
      self.valueHandler = valueHandler
    }
  }

  public typealias Children = [String]
}
