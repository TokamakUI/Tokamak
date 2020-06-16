//
//  Created by Max Desiatov on 11/04/2020.
//

import JavaScriptKit
import Tokamak

public final class DOMNode: Target {
  let ref: JSObjectRef

  init<V: View>(_ view: V, _ ref: JSObjectRef) {
    self.ref = ref
    super.init(view)
  }
}

public final class DOMRenderer: Renderer {
  public private(set) var reconciler: StackReconciler<DOMRenderer>?

  public init<V: View>(_ view: V, _ ref: JSObjectRef) {
    reconciler = StackReconciler(view: view, target: DOMNode(view, ref), renderer: self) { closure in
      let fn = JSFunctionRef.from { _ in
        closure()
        return .undefined
      }
      _ = JSObjectRef.global.setTimeout!(fn, 0)
    }
  }

  public func mountTarget(to parent: DOMNode, with host: MountedHost) -> DOMNode? {
    guard let (html, listeners) = mapAnyView(
      host.view,
      transform: { (html: AnyHTML) in (html.description, html.listeners) }
    )
    else { return nil }

    parent.ref.innerHTML = JSValue(stringLiteral: html)

    guard
      let children = parent.ref.childNodes.object,
      let length = children.length.number,
      length > 0,
      let firstChild = children[0].object
    else { return nil }

    for (event, listener) in listeners {
      _ = firstChild.addEventListener!(event, JSFunctionRef.from {
        listener($0[0].object!)
        return .undefined
      })
    }

    return DOMNode(host.view, firstChild)
  }

  public func update(target: DOMNode, with view: MountedHost) {}

  public func unmount(
    target: DOMNode,
    from parent: DOMNode,
    with view: MountedHost,
    completion: @escaping () -> ()
  ) {}
}
