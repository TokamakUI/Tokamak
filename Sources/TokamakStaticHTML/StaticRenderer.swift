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
//  Created by Carson Katri on 7/20/20.
//

import TokamakCore

public final class HTMLTarget: Target {
  var html: AnyHTML
  var children: [HTMLTarget] = []

  init<V: View>(_ view: V,
                _ html: AnyHTML) {
    self.html = html
    super.init(view)
  }

  init<A: App>(_ app: A,
               _ html: AnyHTML) {
    self.html = html
    super.init(app)
  }
}

extension HTMLTarget {
  var outerHTML: String {
    """
    <\(html.tag)\(html.attributes.isEmpty ? "" : " ")\
    \(html.attributes.map { #"\#($0)="\#($1)""# }.joined(separator: " "))>\
    \(html.innerHTML ?? "")\
    \(children.map(\.outerHTML).joined(separator: "\n"))\
    </\(html.tag)>
    """
  }
}

struct HTMLBody: AnyHTML {
  let tag: String = "body"
  let innerHTML: String? = nil
  let attributes: [String: String] = [
    "style": "margin: 0;" + rootNodeStyles,
  ]
}

public final class StaticRenderer: Renderer {
  public private(set) var reconciler: StackReconciler<StaticRenderer>?

  var rootTarget: HTMLTarget

  static var title: String = ""
  public var html: String {
    """
    <html>
    <head>
      <title>\(Self.title)</title>
      <style>
        \(tokamakStyles)
      </style>
    </head>
    \(rootTarget.outerHTML)
    </html>
    """
  }

  public init<V: View>(_ view: V, _ rootEnvironment: EnvironmentValues? = nil) {
    rootTarget = HTMLTarget(view, HTMLBody())

    reconciler = StackReconciler(
      view: view,
      target: rootTarget,
      environment: EnvironmentValues(),
      renderer: self,
      scheduler: { _ in
        fatalError("Stateful apps cannot be created with TokamakStatic")
      }
    )
  }

  public init<A: App>(_ app: A, _ rootEnvironment: EnvironmentValues? = nil) {
    rootTarget = HTMLTarget(app, HTMLBody())

    reconciler = StackReconciler(
      app: app,
      target: rootTarget,
      environment: EnvironmentValues(),
      renderer: self,
      scheduler: { _ in
        fatalError("Stateful apps cannot be created with TokamakStatic")
      }
    )
  }

  public func mountTarget(to parent: HTMLTarget, with host: MountedHost) -> HTMLTarget? {
    guard let html = mapAnyView(
      host.view,
      transform: { (html: AnyHTML) in html }
    ) else {
      // handle cases like `TupleView`
      if mapAnyView(host.view, transform: { (view: ParentView) in view }) != nil {
        return parent
      }

      return nil
    }

    let node = HTMLTarget(host.view, html)
    parent.children.append(node)
    return node
  }

  public func update(target: HTMLTarget, with host: MountedHost) {
    fatalError("Stateful apps cannot be created with TokamakStatic")
  }

  public func unmount(
    target: HTMLTarget,
    from parent: HTMLTarget,
    with host: MountedHost,
    completion: @escaping () -> ()
  ) {
    fatalError("Stateful apps cannot be created with TokamakStatic")
  }
}
