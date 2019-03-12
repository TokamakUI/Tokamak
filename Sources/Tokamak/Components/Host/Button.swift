//
//  Button.swift
//  Tokamak
//
//  Created by Max Desiatov on 02/12/2018.
//

public struct Button: HostComponent {
  public struct Props: Equatable, ControlProps, StyleProps, Default {
    public static var defaultValue: Props {
      return Props()
    }

    public let handlers: [Event: Handler<()>]
    public let style: Style?
    public let titleColor: Color?
    public let isEnabled: Bool
    public let text: String

    public init(
      _ style: Style? = nil,
      handlers: [Event: Handler<()>] = [:],
      isEnabled: Bool = true,
      onPress: Handler<()>? = nil,
      text: String = "",
      titleColor: Color? = nil
    ) {
      var handlers = handlers
      if let onPress = onPress {
        handlers[.touchUpInside] = onPress
      }
      self.handlers = handlers
      self.style = style
      self.titleColor = titleColor
      self.isEnabled = isEnabled
      self.text = text
    }
  }

  public typealias Children = [AnyNode]
}

extension Button.Props: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self.init(text: value)
  }
}
