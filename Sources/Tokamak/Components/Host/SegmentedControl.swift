//
//  SegmentedControl.swift
//  Tokamak
//
//  Created by Max Desiatov on 05/01/2019.
//

public struct SegmentedControl: HostComponent {
  public struct Props: Equatable, ControlProps, ViewProps,
    ValueControlProps {
    public let handlers: EventHandlers
    public let style: Style?
    public let value: Int
    public let valueHandler: Handler<Int>?
    public let isEnabled: Bool

    public init(
      handlers: EventHandlers = [:],
      isEnabled: Bool = true,
      value: Int,
      valueHandler: Handler<Int>? = nil,
      _ style: Style? = nil
    ) {
      self.handlers = handlers
      self.style = style
      self.value = value
      self.valueHandler = valueHandler
      self.isEnabled = isEnabled
    }
  }

  public typealias Children = [String]
}
