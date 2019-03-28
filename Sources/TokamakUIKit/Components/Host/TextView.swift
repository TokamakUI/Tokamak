//
//  TextView.swift
//  TokamakUIKit
//
//  Created by Matvii Hodovaniuk on 3/27/19.
//

import Tokamak
import UIKit

final class TokamakTextView: UITextView, Default {
  static var defaultValue: TokamakTextView {
    return TokamakTextView()
  }
}

extension TextView: UIViewComponent {
  public typealias RefTarget = UITextView

  static func box(
    for view: TokamakTextView,
    _ viewController: UIViewController,
    _ component: UIKitRenderer.MountedHost,
    _ renderer: UIKitRenderer
  ) -> ViewBox<TokamakTextView> {
    guard let props = component.node.props.value as? Props else {
      fatalError("incorrect props type stored in ListView node")
    }

    return TextViewBox(view, viewController, component, props, renderer)
  }

  static func update(view box: ViewBox<TokamakTextView>,
                     _ props: TextView.Props,
                     _ children: Null) {
    let view = box.view
    if let scrollOptions = props.scrollOptions {
        applyScrollOptions(box, scrollOptions)
    }
    view.allowsEditingTextAttributes = props.allowsEditingTextAttributes
    view.isEditable = props.isEditable
    view.textAlignment = NSTextAlignment(props.textAlignment)
    view.textColor = props.textColor.flatMap { UIColor($0) }
    view.text = props.value
  }
}
