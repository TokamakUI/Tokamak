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
      let fn = JSClosure { _ in
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
    ) else {
      // handle cases like `TupleView`
      if mapAnyView(host.view, transform: { (view: ParentView) in view }) != nil {
        return parent
      }

      return nil
    }

    _ = parent.ref.insertAdjacentHTML!("beforeend", JSValue(stringLiteral: html))

    guard
      let children = parent.ref.childNodes.object,
      let length = children.length.number,
      length > 0,
      let lastChild = children[Int(length) - 1].object
    else { return nil }

    for (event, listener) in listeners {
      _ = lastChild.addEventListener!(event, JSClosure {
        listener($0[0].object!)
        return .undefined
      })
    }

    return DOMNode(host.view, lastChild)
  }

  public func update(target: DOMNode, with host: MountedHost) {
    guard let (html, listeners) = mapAnyView(
      host.view,
      transform: { (html: AnyHTML) in (html.description, html.listeners) }
    ) else { return }

    target.ref.innerHTML = .string(html.description)
    // FIXME: handle listeners here
  }

  public func unmount(
    target: DOMNode,
    from parent: DOMNode,
    with view: MountedHost,
    completion: @escaping () -> ()
  ) {}
}
