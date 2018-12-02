//
//  Button.swift
//  Gluon
//
//  Created by Max Desiatov on 02/12/2018.
//

import UIKit

public struct ButtonProps: Equatable {
  let backgroundColor: Color
  let titleColor: Color
  let onPress: Handler<()>

  public init(backgroundColor: Color = .white,
              onPress: Handler<()>,
              titleColor: Color = .black) {
    self.backgroundColor = backgroundColor
    self.onPress = onPress
    self.titleColor = titleColor
  }
}

public struct Button: HostComponent {
  public typealias Props = ButtonProps
  public typealias Children = String
}

extension UIButton: Default {
}

extension Button: UIKitViewComponent {
  public static func update(_ view: UIButton,
                            _ props: ButtonProps,
                            _ children: String) {
    view.setTitle(children, for: .normal)
  }
}
