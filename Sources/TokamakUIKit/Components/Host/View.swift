//
//  View.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 31/12/2018.
//

import Tokamak
import UIKit

final class TokamakView: UIView, Default {
  public static var defaultValue: TokamakView {
    return TokamakView()
  }
}

extension View: UIViewComponent {
  public typealias RefTarget = UIView

  static func update(view: ViewBox<TokamakView>,
                     _ props: View.Props,
                     _: [AnyNode]) {}
}
