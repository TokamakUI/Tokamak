//
//  Created by Max Desiatov on 11/04/2020.
//

import Tokamak

extension Button: ViewDeferredToRenderer {
  public var deferredBody: AnyView {
    AnyView(HTML(tag: "button"))
  }
}
