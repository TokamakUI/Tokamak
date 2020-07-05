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
import TokamakCore

public final class DOMNode: Target {
  let ref: JSObjectRef
  private var listeners: [String: JSClosure]

  init<V: View>(_ view: V, _ ref: JSObjectRef, _ listeners: [String: Listener] = [:]) {
    self.ref = ref
    self.listeners = [:]
    super.init(view)
    reinstall(listeners)
  }

  /// Removes all existing event listeners on this DOM node and install new ones from
  /// the `listeners` argument
  func reinstall(_ listeners: [String: Listener]) {
    for (event, jsClosure) in self.listeners {
      _ = ref.removeEventListener!(event, jsClosure)
    }
    self.listeners = [:]

    for (event, listener) in listeners {
      let jsClosure = JSClosure {
        listener($0[0].object!)
        return .undefined
      }
      _ = ref.addEventListener!(event, jsClosure)
      self.listeners[event] = jsClosure
    }
  }
}

let log = JSObjectRef.global.console.object!.log.function!
let document = JSObjectRef.global.document.object!
let head = document.head.object!

public final class DOMRenderer: Renderer {
  public private(set) var reconciler: StackReconciler<DOMRenderer>?

  private let rootRef: JSObjectRef

  public init<V: View>(_ view: V, _ ref: JSObjectRef) {
    rootRef = ref
    rootRef.style = "display: flex; width: 100%; height: 100%; justify-content: center; align-items: center; overflow: hidden;"

    let rootStyle = document.createElement!("style").object!
    rootStyle.innerHTML = .string(tokamakStyles)
    _ = head.appendChild!(rootStyle)

    var environment = EnvironmentValues()

    reconciler = StackReconciler(
      view: view,
      target: DOMNode(view, ref),
      renderer: self,
      environment: environment
    ) { closure in
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

    return DOMNode(host.view, lastChild, listeners)
  }

  public func update(target: DOMNode, with host: MountedHost) {
    guard let html = mapAnyView(
      host.view,
      transform: { (html: AnyHTML) in html }
    ) else { return }

    html.update(dom: target)
  }

  public func unmount(
    target: DOMNode,
    from parent: DOMNode,
    with host: MountedHost,
    completion: @escaping () -> ()
  ) {
    defer {
      completion()
    }

    guard mapAnyView(
      host.view,
      transform: { (html: AnyHTML) in html }
    ) != nil else {
      return
    }

    _ = parent.ref.removeChild!(target.ref)
  }
}
