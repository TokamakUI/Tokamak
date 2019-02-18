//
//  UIHostComponent.swift
//  TokamakUIKit
//
//  Created by Max Desiatov on 29/12/2018.
//

import Tokamak
import UIKit

/// Any host component that is supposed to be rendered by `UIKitRenderer`
/// should implement this protocol or any of concrete subprotocols:
/// `UIViewComponent` for `UIView` targets, `UIControlComponent` for
/// `UIControl` targets and `UIValueComponent` for `UIControl` components
/// providing a configurable single value: `UISwitch`, `UISlider`,
/// `UIStepper`, `UIDatePicker`, or `UISegmentedControl`.
protocol UIHostComponent: AnyHostComponent {
  static func mountTarget(
    to parent: UITarget,
    component: UIKitRenderer.MountedHost,
    _ renderer: UIKitRenderer
  ) -> UITarget?

  static func update(target: UITarget, node: AnyNode)

  static func unmount(target: UITarget, completion: @escaping () -> ())
}

extension UIHostComponent {
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
