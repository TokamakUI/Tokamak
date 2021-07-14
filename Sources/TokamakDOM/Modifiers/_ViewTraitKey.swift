//
//  File.swift
//
//
//  Created by Carson Katri on 7/13/21.
//

import TokamakCore
import TokamakStaticHTML

// This extension makes it possible for `_ViewTraitKey`s to be available during mounting
// as it makes the view that modifies the traits a host view.
extension ModifiedContent: DOMPrimitive
  where Content: View, Modifier: _TraitWritingModifierProtocol
{
  var renderedBody: AnyView {
    AnyView(HTML("div") {
      self.content
    })
  }
}

extension _MoveTransition: DOMViewModifier {
  public var attributes: [HTMLAttribute: String] {
    let offset: (String, String)
    switch edge {
    case .leading: offset = ("-100vw", "0")
    case .trailing: offset = ("100vw", "0")
    case .top: offset = ("-100vh", "0")
    case .bottom: offset = ("100vh", "0")
    }
    return [
      "style":
        "transform: translate(\(isActive ? offset.0 : "0"), \(isActive ? offset.1 : "0"));",
    ]
  }
}
