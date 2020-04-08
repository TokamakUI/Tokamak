//
//  NSViewComponent.swift
//  TokamakAppKit
//
//  Created by Max Desiatov on 02/12/2018.
//

import AppKit
import Tokamak

public extension NSView {
  var wantsUpdateLayer: Bool {
    true
  }
}

protocol NSViewComponent: NSHostComponent {
  associatedtype Target: NSView & Default

  static func update(
    view box: ViewBox<Target>,
    _ view: Self
  )

  static func box(
    for view: Target,
    _ viewController: NSViewController,
    _ component: AppKitRenderer.MountedHost,
    _ renderer: AppKitRenderer
  ) -> ViewBox<Target>
}

extension NSViewComponent where Target == Target.DefaultValue {
  static func box(
    for view: Target,
    _ viewController: NSViewController,
    _ component: AppKitRenderer.MountedHost,
    _: AppKitRenderer
  ) -> ViewBox<Target> {
    ViewBox(view, viewController, component.node)
  }

  static func mountTarget(
    to parent: NSTarget,
    component: AppKitRenderer.MountedHost,
    _ renderer: AppKitRenderer
  ) -> NSTarget? {
    let target = Target.defaultValue
    let result = box(for: target, parent.viewController, component, renderer)

    switch parent {
    case let box as ViewBox<TokamakStackView>:
      box.view.addArrangedSubview(target)
    case let box as ViewBox<NSView>:
      box.view.addSubview(target)
    default:
      parentAssertionFailure()
    }

    return result
  }

  static func update(target: NSTarget,
                     node: AnyView) {
    guard let target = target as? ViewBox<Target> else {
      return targetAssertionFailure()
    }
    guard let view = node as? Self else {
      return hostAssertionFailure()
    }

    update(view: target, view)
  }

  static func unmount(target: NSTarget, completion: @escaping () -> ()) {
    switch target {
    case let target as ViewBox<Target>:
      target.view.removeFromSuperview()
    default:
      targetAssertionFailure()
    }

    completion()
  }
}
