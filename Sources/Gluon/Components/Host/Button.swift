//
//  Button.swift
//  Gluon
//
//  Created by Max Desiatov on 02/12/2018.
//

public struct Button: HostComponent {
  public struct Props: Equatable, EventHandlerProps, StyleProps, Default {
    public static var defaultValue: Props {
      return Props()
    }

    public let handlers: [Event: Handler<()>]
    public let style: Style?
    public let titleColor: Color?

    public init(handlers: [Event: Handler<()>] = [:],
                onPress: Handler<()>? = nil,
                _ style: Style? = nil,
                titleColor: Color? = nil) {
      var handlers = handlers
      if let onPress = onPress {
        handlers[.touchUpInside] = onPress
      }
      self.handlers = handlers
      self.style = style
      self.titleColor = titleColor
    }
  }

  public typealias Children = String
}
