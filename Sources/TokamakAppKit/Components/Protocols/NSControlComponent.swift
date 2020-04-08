//
//  NSControlComponent.swift
//  TokamakAppKit
//
//  Created by Max Desiatov on 05/12/2018.
//

import AppKit
import Tokamak

protocol NSControlComponent: NSViewComponent
  where Target: NSControl {
  static func update(control box: ControlBox<Target>,
                     _ view: Self)
}

extension NSControlComponent where Target == Target.DefaultValue {
  static func box(
    for view: Target,
    _ viewController: NSViewController,
    _ component: AppKitRenderer.MountedHost,
    _ renderer: AppKitRenderer
  ) -> ViewBox<Target> {
    ControlBox(view, viewController, component.node)
  }

  static func update(view box: ViewBox<Target>,
                     _ view: Self) {
    guard let box = box as? ControlBox<Target> else {
      targetAssertionFailure()
      return
    }

    update(control: box, view)
  }
}
