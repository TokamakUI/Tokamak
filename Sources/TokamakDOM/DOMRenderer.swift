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

extension EnvironmentValues {
  /// Returns default settings for the DOM environment
  static var defaultEnvironment: Self {
    var environment = EnvironmentValues()
    environment[_ToggleStyleKey] = _AnyToggleStyle(DefaultToggleStyle())
    environment[keyPath: \._defaultAppStorage] = LocalStorage.standard
    _DefaultSceneStorageProvider.default = SessionStorage.standard

    return environment
  }
}

/** `SpacerContainer` is part of TokamakDOM, as not all renderers will handle flexible
 sizing the way browsers do. Their parent element could already know that if a child is
 requesting full width, then it needs to expand.
 */
private extension AnyView {
  var axes: [SpacerContainerAxis] {
    var axes = [SpacerContainerAxis]()
    if let spacerContainer = mapAnyView(self, transform: { (v: SpacerContainer) in v }) {
      if spacerContainer.hasSpacer {
        axes.append(spacerContainer.axis)
      }
      if spacerContainer.fillCrossAxis {
        axes.append(spacerContainer.axis == .horizontal ? .vertical : .horizontal)
      }
    }
    return axes
  }

  var fillAxes: [SpacerContainerAxis] {
    children.flatMap(\.fillAxes) + axes
  }
}

let log = JSObjectRef.global.console.object!.log.function!
let document = JSObjectRef.global.document.object!
let head = document.head.object!

let timeoutScheduler = { (closure: @escaping () -> ()) in
  let fn = JSClosure { _ in
    closure()
    return .undefined
  }
  _ = JSObjectRef.global.setTimeout!(fn, 0)
}

func appendRootStyle(_ rootNode: JSObjectRef) {
  rootNode.style = .string(rootNodeStyles)
  let rootStyle = document.createElement!("style").object!
  rootStyle.innerHTML = .string(tokamakStyles)
  _ = head.appendChild!(rootStyle)
}

public final class DOMRenderer<A: App>: Renderer {
  public typealias AppType = A

  public private(set) var reconciler: StackReconciler<DOMRenderer>?

  private let rootRef: JSObjectRef

  init(_ app: A, _ ref: JSObjectRef, _ rootEnvironment: EnvironmentValues? = nil) {
    rootRef = ref
    appendRootStyle(ref)

    reconciler = StackReconciler(
      app: app,
      target: DOMNode(app, ref),
      environment: .defaultEnvironment,
      renderer: self,
      scheduler: timeoutScheduler
    )
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

    let fillAxes = host.view.fillAxes
    if fillAxes.contains(.horizontal) {
      lastChild.style.object!.width = "100%"
    }
    if fillAxes.contains(.vertical) {
      lastChild.style.object!.height = "100%"
    }

    return DOMNode(host.view, lastChild, listeners)
  }

  public func update(target: DOMNode, with host: MountedHost) {
    guard let html = mapAnyView(host.view, transform: { (html: AnyHTML) in html })
    else { return }

    html.update(dom: target)
  }

  public func unmount(
    target: DOMNode,
    from parent: DOMNode,
    with host: MountedHost,
    completion: @escaping () -> ()
  ) {
    defer { completion() }

    guard mapAnyView(host.view, transform: { (html: AnyHTML) in html }) != nil
    else { return }

    _ = parent.ref.removeChild!(target.ref)
  }
}
