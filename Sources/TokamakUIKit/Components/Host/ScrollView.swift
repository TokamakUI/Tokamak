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
  public typealias RefTarget = UIScrollView

  static func update(
    view box: ViewBox<TokamakScrollView>,
    _ props: ScrollView.Props,
    _ children: AnyNode
  ) {
    if let scrollOptions = props.scrollOptions {
      applyScrollOptions(box, scrollOptions)
    }
  }

  static func unmount(
    target: UITarget,
    from parent: UITarget,
    completion: @escaping () -> ()
  ) {
    completion()
  }
}
