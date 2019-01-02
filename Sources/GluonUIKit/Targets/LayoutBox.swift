//
//  LayoutBox.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 01/01/2019.
//

import Gluon
import UIKit

final class LayoutBox: ViewBox<UIView> {
  let props: LayoutConstraints.Props

  init(_ viewBox: ViewBox<UIView>, _ props: LayoutConstraints.Props) {
    self.props = props

    super.init(viewBox.view, viewBox.viewController)
  }
}
