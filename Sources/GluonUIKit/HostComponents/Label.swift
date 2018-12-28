//
//  Label.swift
//  Gluon
//
//  Created by Max Desiatov on 02/12/2018.
//

import Gluon
import UIKit

public struct Label: HostComponent {
  public typealias Props = Null
  public typealias Children = String
}

extension UILabel: Default {}

extension Label: UIKitViewComponent {
  public static func update(_ view: UILabel, _: Null, _ children: String) {
    view.text = children
  }
}
