//
//  Created by Max Desiatov on 08/04/2020.
//

public struct AnyView: View {
  let type: Any.Type
  let view: Any

  let bodyClosure: () -> AnyView

  public init<V>(_ view: V) where V: View {
    if let anyView = view as? AnyView {
      type = anyView.type
      self.view = anyView.view
      bodyClosure = anyView.bodyClosure
    } else {
      type = V.self
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
