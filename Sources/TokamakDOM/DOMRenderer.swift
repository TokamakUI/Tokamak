// Copyright 2020 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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

let log = JSObjectRef.global.console.object!.log.function!

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
    guard let (outerHTML, listeners) = mapAnyView(
      host.view,
      transform: { (html: AnyHTML) in (html.outerHTML, html.listeners) }
    ) else {
      // handle cases like `TupleView`
      if mapAnyView(host.view, transform: { (view: ParentView) in view }) != nil {
        return parent
      }

      return nil
    }

    _ = parent.ref.insertAdjacentHTML!("beforeend", JSValue(stringLiteral: outerHTML))

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
    guard let html = mapAnyView(
      host.view,
      transform: { (html: AnyHTML) in html }
    ) else { return }

    html.update(dom: target.ref)
  }

  public func unmount(
    target: DOMNode,
    from parent: DOMNode,
    with view: MountedHost,
    completion: @escaping () -> ()
  ) {}
}
