//
//  File.swift
//
//
//  Created by Carson Katri on 2/7/22.
//

import Foundation

public struct ViewInputs<V: View> {
  let view: V
  let proposedSize: CGSize?
  let environment: EnvironmentBox
}

public struct ViewOutputs {
  /// A container for a reference to the current `EnvironmentValues`.
  /// This is stored as a reference to avoid copying the environment when unnecessary.
  let environment: EnvironmentBox
  let preferences: _PreferenceStore
  let size: CGSize
  let layoutComputer: LayoutComputer?
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
    size: CGSize? = nil,
    layoutComputer: LayoutComputer? = nil
  ) {
    // Only replace the EnvironmentBox when we change the environment. Otherwise the same box can be reused.
    self.environment = environment.map(EnvironmentBox.init) ?? inputs.environment
    self.preferences = preferences ?? .init()
    self.size = size ?? inputs.proposedSize ?? .zero
    self.layoutComputer = layoutComputer
  }
}

protocol LayoutComputer {
  func proposeSize<V: View>(for child: V, at index: Int) -> CGSize
}

public extension View {
  static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    .init(inputs: inputs)
  }
}

public extension ModifiedContent where Content: View, Modifier: ViewModifier {
  static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    var environment = inputs.environment.environment
    if let environmentWriter = inputs.view.modifier as? EnvironmentModifier {
      environmentWriter.modifyEnvironment(&environment)
    }
    return .init(inputs: inputs, environment: environment)
  }

  func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    visitor.visit(modifier.body(content: .init(modifier: modifier, view: content)))
  }
}
