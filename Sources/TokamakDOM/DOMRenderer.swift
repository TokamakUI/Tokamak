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

import JavaScriptEventLoop
import JavaScriptKit
import OpenCombineJS
@_spi(TokamakCore) import TokamakCore
import TokamakStaticHTML

public typealias Sanitizers = TokamakStaticHTML.Sanitizers

extension EnvironmentValues {
  /// Returns default settings for the DOM environment
  static var defaultEnvironment: Self {
    var environment = EnvironmentValues()

    // `.toggleStyle` property is internal
    environment[_ToggleStyleKey.self] = _AnyToggleStyle(DefaultToggleStyle())

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

    if #available(macOS 10.15, *) {
      JavaScriptEventLoop.installGlobalExecutor()
    }

    let scheduler = JSScheduler()
    self.scheduler = scheduler
    reconciler = StackReconciler(
      app: app,
      target: DOMNode(ref),
      environment: .defaultEnvironment.merging(rootEnvironment),
      renderer: self
    ) { scheduler.schedule(options: nil, $0) }
  }

  private func fixSpacers(host: MountedHost, target: JSObject) {
    let fillAxes = host.view.fillAxes
    if fillAxes.contains(.horizontal) {
      target.style.object!.width = "100%"
    }
    if fillAxes.contains(.vertical) {
      target.style.object!.height = "100%"
    }
  }

  public func mountTarget(
    before sibling: DOMNode?,
    to parent: DOMNode,
    with host: MountedHost
  ) -> DOMNode? {
    guard let anyHTML: AnyHTML = mapAnyView(host.view, transform: { $0 }) else {
      // handle `GroupView` cases (such as `TupleView`, `Group` etc)
      if mapAnyView(host.view, transform: { (view: ParentView) in view }) != nil {
        return parent
      }

      return nil
    }

    // Transition the insertion.
    let transition = _AnyTransitionProxy(host.viewTraits.transition)
      .resolve(in: host.environmentValues)
    var additionalAttributes = [HTMLAttribute: String]()
    var runTransition: ((DOMNode) -> ())?
    if host.viewTraits.canTransition,
       let animation = transition.insertionAnimation ?? host.transaction.animation
    {
      // Apply the active insertion modifier on mount.
      additionalAttributes = apply(
        transition: transition, \.insertion,
        as: \.active,
        to: host.view
      )
      runTransition = { node in
        anyHTML.update(
          dom: node,
          computeStart: false,
          additionalAttributes: self.apply(
            transition: transition, \.insertion,
            as: \.identity,
            to: host.view
          ),
          transaction: .init(animation: animation)
        )
      }
    }

    let maybeNode: JSObject?
    if let sibling = sibling {
      _ = sibling.ref.insertAdjacentHTML!(
        "beforebegin",
        anyHTML.outerHTML(
          shouldSortAttributes: false, additonalAttributes: additionalAttributes, children: []
        )
      )
      maybeNode = sibling.ref.previousSibling.object
    } else {
      _ = parent.ref.insertAdjacentHTML!(
        "beforeend",
        anyHTML.outerHTML(
          shouldSortAttributes: false, additonalAttributes: additionalAttributes, children: []
        )
      )

      guard
        let children = parent.ref.childNodes.object,
        let length = children.length.number,
        length > 0
      else { return nil }

      maybeNode = children[Int(length) - 1].object
    }

    guard let resultingNode = maybeNode else { return nil }

    fixSpacers(host: host, target: resultingNode)

    let node = DOMNode(host.view, resultingNode, (anyHTML as? AnyDynamicHTML)?.listeners ?? [:])

    runTransition?(node)
    return node
  }

  func update(target: DOMNode, with host: MountedHost) {
    guard let html = mapAnyView(host.view, transform: { (html: AnyHTML) in html })
    else { return }

    html.update(
      dom: target,
      additionalAttributes: [:],
      transaction: host.transaction
    )

    fixSpacers(host: host, target: target.ref)
  }

  func unmount(
    target: DOMNode,
    from parent: DOMNode,
    with task: UnmountHostTask<DOMRenderer>
  ) {
    guard let anyHTML = mapAnyView(task.host.view, transform: { (html: AnyHTML) in html })
    else { return task.finish() }

    // Transition the removal.
    let transition = _AnyTransitionProxy(task.host.viewTraits.transition)
      .resolve(in: task.host.environmentValues)
    if task.host.viewTraits.canTransition,
       let animation = transition.removalAnimation ?? task.host.transaction.animation
    {
      // First, apply the identity removal modifier /without/ animation
      // to be in the initial state.
      anyHTML.update(
        dom: target,
        additionalAttributes: apply(
          transition: transition, \.removal,
          as: \.identity,
          to: task.host.view
        ),
        transaction: .init(animation: nil)
      )

      // Then apply the active removal modifier /with/ animation.
      anyHTML.update(
        dom: target,
        additionalAttributes: apply(
          transition: transition, \.removal,
          as: \.active,
          to: task.host.view
        ),
        transaction: .init(animation: animation)
      )

      _ = JSObject.global.setTimeout!(
        JSOneshotClosure { _ in
          guard !task.isCancelled else { return .undefined }
          _ = try? parent.ref.throwing.removeChild!(target.ref)
          task.finish()
          return .undefined
        },
        _AnimationProxy(animation).resolve().duration * 1000
      )

      return
    }

    _ = try? parent.ref.throwing.removeChild!(target.ref)
    task.finish()
  }

  func primitiveBody(for view: Any) -> AnyView? {
    (view as? DOMPrimitive)?.renderedBody ?? (view as? _HTMLPrimitive)?.renderedBody
  }

  func isPrimitiveView(_ type: Any.Type) -> Bool {
    type is DOMPrimitive.Type || type is _HTMLPrimitive.Type
  }

  private func apply(
    transition: _AnyTransitionBox.ResolvedTransition,
    _ direction: KeyPath<
      _AnyTransitionBox.ResolvedTransition,
      [_AnyTransitionBox.ResolvedTransition.Transition]
    >,
    as state: KeyPath<
      _AnyTransitionBox.ResolvedTransition.Transition,
      (AnyView) -> AnyView
    >,
    to view: AnyView
  ) -> [HTMLAttribute: String] {
    transition[keyPath: direction].reduce([HTMLAttribute: String]()) {
      if let modifiedContent = mapAnyView(
        $1[keyPath: state](view),
        transform: { (v: _AnyModifiedContent) in v }
      ) {
        return $0.merging(
          modifiedContent.anyModifier.attributes,
          uniquingKeysWith: +
        )
      } else {
        return $0
      }
    }
  }
}

protocol DOMPrimitive {
  var renderedBody: AnyView { get }
}
