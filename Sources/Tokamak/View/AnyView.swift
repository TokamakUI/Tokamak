//
//  Created by Max Desiatov on 08/04/2020.
//

public struct AnyView: View {
  let type: Any.Type
  let bodyType: Any.Type
  var view: Any

  // needs to take a fresh version of `view` as an argument, otherwise it captures the old view value
  let bodyClosure: (Any) -> AnyView

  public init<V>(_ view: V) where V: View {
    if let anyView = view as? AnyView {
      type = anyView.type
      bodyType = anyView.bodyType
      self.view = anyView.view
      bodyClosure = anyView.bodyClosure
    } else {
      type = V.self
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
