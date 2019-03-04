//
//  ScrollView.swift
//  TokamakUIKit
//
//  Created by Matvii Hodovaniuk on 2/28/19.
//

import Tokamak
import UIKit

final class TokamakScrollView: UIScrollView, Default {
  static var defaultValue: TokamakScrollView {
    return TokamakScrollView()
  }
}

extension ScrollView: UIViewComponent {
  static func update(view box: ViewBox<TokamakScrollView>, _ props: ScrollView.Props, _ children: AnyNode) {
  }

  public typealias RefTarget = UIScrollView
}
