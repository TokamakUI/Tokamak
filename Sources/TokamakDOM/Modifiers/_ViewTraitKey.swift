//
//  File.swift
//
//
//  Created by Carson Katri on 7/13/21.
//

import TokamakCore
import TokamakStaticHTML

extension _MoveTransition: DOMViewModifier {
  public var attributes: [HTMLAttribute: String] {
    let offset: (String, String)
    switch edge {
    case .leading: offset = ("-100%", "0")
    case .trailing: offset = ("100%", "0")
    case .top: offset = ("-100%", "0")
    case .bottom: offset = ("100%", "0")
    }
    return [
      "style":
        "transform: translate(\(isActive ? offset.0 : "0"), \(isActive ? offset.1 : "0"));",
    ]
  }
}
