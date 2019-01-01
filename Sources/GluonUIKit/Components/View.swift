//
//  View.swift
//  GluonUIKit
//
//  Created by Max Desiatov on 31/12/2018.
//

import Gluon
import UIKit

final class GluonUIView: UIView, Default {
  public static var defaultValue: GluonUIView {
    return GluonUIView()
  }
}

extension View: UIViewComponent {
  static func update(_ view: ViewBox<GluonUIView>,
                     _ props: View.Props,
                     _: [Node]) {}
}
