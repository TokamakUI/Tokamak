//
//  Button.swift
//  Gluon
//
//  Created by Max Desiatov on 02/12/2018.
//

public struct Button: HostComponent {
  public struct Props: Equatable, ControlProps, StyleProps, Default {
    public static var defaultValue: Props {
      return Props()
    }

    public var isEnabled: Bool

    public let handlers: [Event: Handler<()>]
    public let style: Style?
    public let titleColor: Color?

    public init(handlers: [Event: Handler<()>] = [:],
                onPress: Handler<()>? = nil,
                _ style: Style? = nil,
                titleColor: Color? = nil,
                isEnabled: Bool = true) {
      var handlers = handlers
      if let onPress = onPress {
        handlers[.touchUpInside] = onPress
      }
      self.handlers = handlers
      self.style = style
      self.titleColor = titleColor
      self.isEnabled = isEnabled
    }
  }

  public typealias Children = String
}
