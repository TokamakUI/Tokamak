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

@_spi(TokamakCore) import TokamakCore

extension EnvironmentValues {
  /// Returns default settings for the static HTML environment
  static var defaultEnvironment: Self {
    var environment = EnvironmentValues()
    environment[_ColorSchemeKey.self] = .light

    return environment
  }
}

public final class HTMLTarget: Target {
  var html: AnyHTML
  var children: [HTMLTarget] = []

  public var view: AnyView

  init<V: View>(_ view: V, _ html: AnyHTML) {
    self.html = html
    self.view = AnyView(view)
  }

  init(_ html: AnyHTML) {
    self.html = html
    view = AnyView(EmptyView())
  }
}

extension HTMLTarget {
  func outerHTML(shouldSortAttributes: Bool) -> String {
    html.outerHTML(shouldSortAttributes: shouldSortAttributes, children: children)
  }
}

struct HTMLBody: AnyHTML {
  let tag: String = "body"
  public func innerHTML(shouldSortAttributes: Bool) -> String? { nil }
  let attributes: [HTMLAttribute: String] = [
    "style": "margin: 0;" + rootNodeStyles,
  ]
}

extension HTMLMeta.MetaTag {
  func outerHTML() -> String {
    switch self {
    case let .charset(charset):
      return #"<meta charset="\#(charset)">"#
    case let .name(name, content):
      return #"<meta name="\#(name)" content="\#(content)">"#
    case let .property(property, content):
      return #"<meta property="\#(property)" content="\#(content)">"#
    case let .httpEquiv(httpEquiv, content):
      return #"<meta http-equiv="\#(httpEquiv)" content="\#(content)">"#
    }
  }
}

public final class StaticHTMLRenderer: Renderer {
  private var reconciler: StackReconciler<StaticHTMLRenderer>?

  var rootTarget: HTMLTarget

  var title: String {
    reconciler?.preferenceStore.value(forKey: HTMLTitlePreferenceKey.self).value ?? ""
  }

  var meta: [HTMLMeta.MetaTag] {
    reconciler?.preferenceStore.value(forKey: HTMLMetaPreferenceKey.self).value ?? []
  }

  public func render(shouldSortAttributes: Bool = false) -> String {
    """
    <html>
    <head>
      <title>\(title)</title>\(
        !meta.isEmpty ? "\n  " + meta.map { $0.outerHTML() }.joined(separator: "\n  ") : ""
      )
      <style>
        \(tokamakStyles)
      </style>
    </head>
    \(rootTarget.outerHTML(shouldSortAttributes: shouldSortAttributes))
    </html>
    """
  }

  /// Renders only the root child of the top level `<body>` tag.
  public func renderRoot(shouldSortAttributes: Bool = false) -> String {
    rootTarget.children.first?.outerHTML(shouldSortAttributes: shouldSortAttributes) ?? ""
  }

  public init<V: View>(_ view: V, _ rootEnvironment: EnvironmentValues? = nil) {
    rootTarget = HTMLTarget(view, HTMLBody())

    reconciler = StackReconciler(
      view: view,
      target: rootTarget,
      environment: .defaultEnvironment.merging(rootEnvironment),
      renderer: self,
      scheduler: { _ in
        fatalError("Stateful apps cannot be created with TokamakStaticHTML")
      }
    )
  }

  public init<A: App>(_ app: A, _ rootEnvironment: EnvironmentValues? = nil) {
    rootTarget = HTMLTarget(HTMLBody())

    reconciler = StackReconciler(
      app: app,
      target: rootTarget,
      environment: .defaultEnvironment.merging(rootEnvironment),
      renderer: self,
      scheduler: { _ in
        fatalError("Stateful apps cannot be created with TokamakStaticHTML")
      }
    )
  }

  public func mountTarget(
    before _: HTMLTarget?,
    to parent: HTMLTarget,
    with host: MountedHost
  ) -> HTMLTarget? {
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
    fatalError("Stateful apps cannot be created with TokamakStaticHTML")
  }

  public func unmount(
    target: HTMLTarget,
    from parent: HTMLTarget,
    with host: UnmountHostTask<StaticHTMLRenderer>
  ) {
    fatalError("Stateful apps cannot be created with TokamakStaticHTML")
  }

  public func isPrimitiveView(_ type: Any.Type) -> Bool {
    type is _HTMLPrimitive.Type
  }

  public func primitiveBody(for view: Any) -> AnyView? {
    (view as? _HTMLPrimitive)?.renderedBody
  }
}

public protocol _HTMLPrimitive {
  var renderedBody: AnyView { get }
}
