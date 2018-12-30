//
//  Button.swift
//  Gluon
//
//  Created by Max Desiatov on 02/12/2018.
//

public struct ButtonProps: Equatable, EventHandlerProps {
  public let backgroundColor: Color?
  public let titleColor: Color?
  public let handlers: [Event: Handler<()>]

  public init(backgroundColor: Color? = nil,
              handlers: [Event: Handler<()>] = [:],
              titleColor: Color? = nil) {
    self.backgroundColor = backgroundColor
    self.handlers = handlers
    self.titleColor = titleColor
  }
}

public struct Button: HostComponent {
  public typealias Props = ButtonProps
  public typealias Children = String
}
