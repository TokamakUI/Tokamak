//
//  NSControlComponent.swift
//  TokamakAppKit
//
//  Created by Max Desiatov on 05/12/2018.
//

import AppKit
import Tokamak

protocol NSControlComponent: NSViewComponent
  where Props: ControlProps, Target: NSControl {
  static func update(control box: ControlBox<Target>,
                     _ props: Props,
                     _ children: Children)
}

extension NSControlComponent where Target == Target.DefaultValue {
  static func box(
    for view: Target,
    _ viewController: NSViewController,
    _ component: AppKitRenderer.MountedHost,
    _ renderer: AppKitRenderer
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
