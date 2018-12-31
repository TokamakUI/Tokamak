//
//  Button.swift
//  Gluon
//
//  Created by Max Desiatov on 02/12/2018.
//

public struct Button: HostComponent {
  public struct Props: Equatable, EventHandlerProps, StyleProps {
    public let handlers: [Event: Handler<()>]
    public let style: Style?
    public let titleColor: Color?

    public init(handlers: [Event: Handler<()>] = [:],
                style: Style? = nil,
                titleColor: Color? = nil) {
      self.handlers = handlers
      self.style = style
      self.titleColor = titleColor
    }
  }

  public typealias Children = String
}
