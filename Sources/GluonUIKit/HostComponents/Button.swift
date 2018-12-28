//
//  Button.swift
//  Gluon
//
//  Created by Max Desiatov on 02/12/2018.
//

import Gluon
import UIKit

public struct ButtonProps: Equatable, EventHandlerProps {
  public let backgroundColor: Color
  public let titleColor: Color
  public let handlers: [Event: Handler<()>]

  public init(backgroundColor: Color = .white,
              handlers: [Event: Handler<()>] = [:],
              titleColor: Color = .black) {
    self.backgroundColor = backgroundColor
    self.handlers = handlers
    self.titleColor = titleColor
  }
}

public struct Button: HostComponent {
  public typealias Props = ButtonProps
  public typealias Children = String
}

extension UIButton: Default {}

extension Button: UIKitControlComponent {
  public static func update(_ view: UIButton,
                            _ props: ButtonProps,
                            _ children: String) {
    view.setTitleColor(UIColor(props.titleColor), for: .normal)
    view.setTitle(children, for: .normal)
  }
}
