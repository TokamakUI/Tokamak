// Copyright 2020-2021 Tokamak contributors
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
import OpenCombineJS
@_spi(TokamakCore) import TokamakCore
import TokamakStaticHTML

extension EnvironmentValues {
  /// Returns default settings for the DOM environment
  static var defaultEnvironment: Self {
    var environment = EnvironmentValues()

    // `.toggleStyle` property is internal
    environment[_ToggleStyleKey] = _AnyToggleStyle(DefaultToggleStyle())

    environment.colorScheme = .init(matchMediaDarkScheme: matchMediaDarkScheme)
    environment._defaultAppStorage = LocalStorage.standard
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

let global = JSObject.global
let window = global.window.object!
let matchMediaDarkScheme = window.matchMedia!("(prefers-color-scheme: dark)").object!
let log = global.console.object!.log.function!
let document = global.document.object!
let body = document.body.object!
let head = document.head.object!

func appendRootStyle(_ rootNode: JSObject) {
  rootNode.style = .string(rootNodeStyles)
  let rootStyle = document.createElement!("style").object!
  rootStyle.innerHTML = .string(tokamakStyles)
  _ = head.appendChild!(rootStyle)
}

final class DOMRenderer: Renderer {
  private var reconciler: StackReconciler<DOMRenderer>?

  private let rootRef: JSObject

  private let scheduler: JSScheduler

  init<A: App>(_ app: A, _ ref: JSObject, _ rootEnvironment: EnvironmentValues? = nil) {
    rootRef = ref
    appendRootStyle(ref)

    let scheduler = JSScheduler()
    self.scheduler = scheduler
    reconciler = StackReconciler(
      app: app,
      target: DOMNode(ref),
      environment: .defaultEnvironment,
      renderer: self
    ) { scheduler.schedule(options: nil, $0) }
  }

  public func mountTarget(
    before sibling: DOMNode?,
    to parent: DOMNode,
    with host: MountedHost
  ) -> DOMNode? {
    guard let anyHTML = mapAnyView(
      host.view,
      transform: { (html: AnyHTML) in html }
    ) else {
      // handle `GroupView` cases (such as `TupleView`, `Group` etc)
      if mapAnyView(host.view, transform: { (view: ParentView) in view }) != nil {
        return parent
      }

      return nil
    }

    let maybeNode: JSObject?
    if let sibling = sibling {
      _ = sibling.ref.insertAdjacentHTML!("beforebegin", anyHTML.outerHTML)
      maybeNode = sibling.ref.previousSibling.object
    } else {
      _ = parent.ref.insertAdjacentHTML!("beforeend", anyHTML.outerHTML)

      guard
        let children = parent.ref.childNodes.object,
        let length = children.length.number,
        length > 0
      else { return nil }

      maybeNode = children[Int(length) - 1].object
    }

    guard let resultingNode = maybeNode else { return nil }

    let fillAxes = host.view.fillAxes
    if fillAxes.contains(.horizontal) {
      resultingNode.style.object!.width = "100%"
    }
    if fillAxes.contains(.vertical) {
      resultingNode.style.object!.height = "100%"
    }

    if let dynamicHTML = anyHTML as? AnyDynamicHTML {
      return DOMNode(host.view, resultingNode, dynamicHTML.listeners)
    } else {
      return DOMNode(host.view, resultingNode, [:])
    }
  }

  func update(target: DOMNode, with host: MountedHost) {
    guard let html = mapAnyView(host.view, transform: { (html: AnyHTML) in html })
    else { return }

    html.update(dom: target)
  }

  func unmount(
    target: DOMNode,
    from parent: DOMNode,
    with host: MountedHost,
    completion: @escaping () -> ()
  ) {
    defer { completion() }

    guard mapAnyView(host.view, transform: { (html: AnyHTML) in html }) != nil
    else { return }

    _ = try? parent.ref.throwing.removeChild!(target.ref)
  }
}
