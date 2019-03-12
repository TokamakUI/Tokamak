//
//  NSHostComponent.swift
//  TokamakAppKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import AppKit
import Tokamak

/// Any host component that is supposed to be rendered by `AppKitRenderer`
/// should implement this protocol or any of concrete subprotocols:
/// `NSViewComponent` for `NSView` targets, `NSControlComponent` for
/// `NSControl` targets and `NSValueComponent` for `NSControl` components
/// providing a configurable single value: `NSSlider`,
/// `NSStepper`, `NSDatePicker`, or `NSSegmentedControl`.
protocol NSHostComponent: AnyHostComponent {
  static func mountTarget(
    to parent: NSTarget,
    component: AppKitRenderer.MountedHost,
    _ renderer: AppKitRenderer
  ) -> NSTarget?

  static func update(target: NSTarget, node: AnyNode)

  static func unmount(target: NSTarget, completion: @escaping () -> ())
}

extension NSHostComponent {
  static func targetAssertionFailure(_ function: String = #function) {
    typeAssertionFailure("target", function)
  }

  static func childrenAssertionFailure(_ function: String = #function) {
    typeAssertionFailure("children", function)
  }

  static func propsAssertionFailure(_ function: String = #function) {
    typeAssertionFailure("props", function)
  }

  static func parentAssertionFailure(_ function: String = #function) {
    typeAssertionFailure("parent target", function)
  }

  static func boxAssertionFailure(_ function: String = #function) {
    typeAssertionFailure("box", function)
  }

  private static func typeAssertionFailure(_ type: String, _ function: String) {
    assertionFailure("""
    UIKitHostComponent passed unsupported \(type) type in \(function)
    """)
  }
}
