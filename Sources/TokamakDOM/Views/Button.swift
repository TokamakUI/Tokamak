//
//  Created by Max Desiatov on 11/04/2020.
//

import Tokamak

public typealias Button = Tokamak.Button

extension Button: ViewDeferredToRenderer where Label == Text {
  public var deferredBody: AnyView {
    AnyView(HTML(
      tag: "button",
      listeners: ["click": { _ in action() }]
    ) { Text(buttonLabel(self)) })
  }
}
