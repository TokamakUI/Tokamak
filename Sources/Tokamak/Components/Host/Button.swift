//
//  Button.swift
//  Tokamak
//
//  Created by Max Desiatov on 02/12/2018.
//

public struct Button: HostComponent {
  public struct Props: Equatable, ControlProps, ViewProps, Default {
    public static var defaultValue: Props {
      return Props()
    }

    public let handlers: [Event: Handler<()>]
    public let style: Style?
    public let titleColor: Color?
    public let isEnabled: Bool

    public init(
      _ style: Style? = nil,
      handlers: [Event: Handler<()>] = [:],
      isEnabled: Bool = true,
      onPress: Handler<()>? = nil,
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
    }
  }

  public typealias Children = String
}
