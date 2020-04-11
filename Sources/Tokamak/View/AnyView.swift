//
//  Created by Max Desiatov on 08/04/2020.
//

import Runtime

public struct AnyView: View {
  let type: Any.Type
  let typeConstructorName: String
  let bodyType: Any.Type
  var view: Any

  // needs to take a fresh version of `view` as an argument, otherwise it captures the old view value
  let bodyClosure: (Any) -> AnyView

  public init<V>(_ view: V) where V: View {
    if let anyView = view as? AnyView {
      type = anyView.type
      typeConstructorName = anyView.typeConstructorName
      bodyType = anyView.bodyType
      self.view = anyView.view
      bodyClosure = anyView.bodyClosure
    } else {
      type = V.self

      // FIXME: no idea if using `mangledName` is reliable, but seems to be the only way to get
      // a name of a type constructor in runtime. Should definitely check if these are different
      // across modules, otherwise can cause problems with views with same names in different
      // modules.

      // swiftlint:disable:next force_try
      typeConstructorName = try! typeInfo(of: type).mangledName

      bodyType = V.Body.self
      self.view = view
      // swiftlint:disable:next force_cast
      bodyClosure = { AnyView(($0 as! V).body) }
    }
  }
}

extension AnyView: ParentView {
  var children: [AnyView] {
    (view as? ParentView)?.children ?? []
  }
}
