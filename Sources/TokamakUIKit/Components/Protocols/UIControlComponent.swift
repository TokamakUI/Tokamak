//
//  UIControlComponent.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 05/12/2018.
//

import Tokamak
import UIKit

protocol UIControlComponent: UIViewComponent
  where Props: ControlProps, Target: UIControl {
  static func update(control box: ControlBox<Target>,
                     _ props: Props,
                     _ children: Children)
}

extension UIControlComponent where Target == Target.DefaultValue {
  static func box(
    for view: Target,
    _ viewController: UIViewController,
    _ component: UIKitRenderer.MountedHost,
    _ renderer: UIKitRenderer
  ) -> ViewBox<Target> {
    return ControlBox(view, viewController, component.node)
  }

  static func update(view box: ViewBox<Target>,
                     _ props: Props,
                     _ children: Children) {
    guard let box = box as? ControlBox<Target> else {
      targetAssertionFailure()
      return
    }

    box.view.isEnabled = props.isEnabled
    box.bind(handlers: props.handlers)
    update(control: box, props, children)
  }
}
