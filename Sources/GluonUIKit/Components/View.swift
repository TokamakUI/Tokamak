//
//  View.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 31/12/2018.
//

import Gluon
import UIKit

final class GluonView: UIView, Default {
  public static var defaultValue: GluonView {
    return GluonView()
  }
}

extension View: UIViewComponent {
  static func update(view: ViewBox<GluonView>,
                     _ props: View.Props,
                     _: [Node]) {}
}
