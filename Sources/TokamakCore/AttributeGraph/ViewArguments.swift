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
  let environment: EnvironmentValues
}

public struct ViewOutputs {
  let environment: EnvironmentValues
  let preferences: _PreferenceStore
  let size: CGSize
  let layoutComputer: LayoutComputer?
}

extension ViewOutputs {
  init<V: View>(
    inputs: ViewInputs<V>,
    environment: EnvironmentValues? = nil,
    preferences: _PreferenceStore? = nil,
    size: CGSize? = nil,
    layoutComputer: LayoutComputer? = nil
  ) {
    self.environment = environment ?? inputs.environment
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
    var environment = inputs.environment
    if let environmentWriter = inputs.view.modifier as? EnvironmentModifier {
      environmentWriter.modifyEnvironment(&environment)
    }
    return .init(inputs: inputs, environment: environment)
  }

  func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    visitor.visit(modifier.body(content: .init(modifier: modifier, view: content)))
  }
}
