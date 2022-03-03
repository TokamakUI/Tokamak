//
//  File.swift
//
//
//  Created by Carson Katri on 2/7/22.
//

import Foundation

/// Data passed to `_makeView` to create the `ViewOutputs` used in reconciling/rendering.
public struct ViewInputs<V: View> {
  let view: V
  let environment: EnvironmentBox
}

/// Data used to reconcile and render a `View` and its children.
public struct ViewOutputs {
  /// A container for the current `EnvironmentValues`.
  /// This is stored as a reference to avoid copying the environment when unnecessary.
  let environment: EnvironmentBox
  let preferences: _PreferenceStore
  let makeLayoutComputer: (CGSize) -> LayoutComputer
  /// The `LayoutComputer` used to propose sizes for the children of this view.
  var layoutComputer: LayoutComputer!
}

final class EnvironmentBox {
  let environment: EnvironmentValues

  init(_ environment: EnvironmentValues) {
    self.environment = environment
  }
}

extension ViewOutputs {
  init<V: View>(
    inputs: ViewInputs<V>,
    environment: EnvironmentValues? = nil,
    preferences: _PreferenceStore? = nil,
    layoutComputer: ((CGSize) -> LayoutComputer)? = nil
  ) {
    // Only replace the EnvironmentBox when we change the environment. Otherwise the same box can be reused.
    self.environment = environment.map(EnvironmentBox.init) ?? inputs.environment
    self.preferences = preferences ?? .init()
    makeLayoutComputer = layoutComputer ?? { proposedSize in
      ShrinkWrapLayout(proposedSize: proposedSize)
    }
  }
}

public extension View {
  // By default, we simply pass the inputs through without modifications
  // or layout considerations.
  static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    .init(inputs: inputs)
  }
}

public extension ModifiedContent where Content: View, Modifier: ViewModifier {
  static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    // Update the environment if needed.
    var environment = inputs.environment.environment
    if let environmentWriter = inputs.view.modifier as? EnvironmentModifier {
      environmentWriter.modifyEnvironment(&environment)
    }
    return .init(inputs: inputs, environment: environment)
  }

  func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    // Visit the computed body of the modifier.
    visitor.visit(modifier.body(content: .init(modifier: modifier, view: content)))
  }
}
