//
//  Created by Max Desiatov on 08/04/2020.
//

public struct AnyView: View {
  let type: Any.Type
  let bodyType: Any.Type
  let view: Any

  let bodyClosure: () -> AnyView

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
      bodyClosure = { AnyView(view.body) }
    }
  }
}

extension AnyView: ParentView {
  var children: [AnyView] {
    (view as? ParentView)?.children ?? []
  }
}
