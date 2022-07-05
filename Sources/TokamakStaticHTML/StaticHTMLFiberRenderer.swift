// Copyright 2022 Tokamak contributors
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
//  Created by Carson Katri on 2/6/22.
//

import Foundation
import OpenCombineShim
@_spi(TokamakCore)
import TokamakCore

public final class HTMLElement: FiberElement, CustomStringConvertible {
  public struct Content: FiberElementContent, Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.tag == rhs.tag
        && lhs.attributes == rhs.attributes
        && lhs.innerHTML == rhs.innerHTML
        && lhs.children.map(\.content) == rhs.children.map(\.content)
    }

    var tag: String
    var attributes: [HTMLAttribute: String]
    var innerHTML: String?
    var children: [HTMLElement] = []

    public init<V>(from primitiveView: V, useDynamicLayout: Bool) where V: View {
      guard let primitiveView = primitiveView as? HTMLConvertible else { fatalError() }
      tag = primitiveView.tag
      attributes = primitiveView.attributes(useDynamicLayout: useDynamicLayout)
      innerHTML = primitiveView.innerHTML
    }

    public init(
      tag: String,
      attributes: [HTMLAttribute: String],
      innerHTML: String?,
      children: [HTMLElement]
    ) {
      self.tag = tag
      self.attributes = attributes
      self.innerHTML = innerHTML
      self.children = children
    }
  }

  public var content: Content

  public init(from content: Content) {
    self.content = content
  }

  public init(
    tag: String,
    attributes: [HTMLAttribute: String],
    innerHTML: String?,
    children: [HTMLElement]
  ) {
    content = .init(
      tag: tag,
      attributes: attributes,
      innerHTML: innerHTML,
      children: children
    )
  }

  public func update(with content: Content) {
    self.content = content
  }

  public var description: String {
    """
    <\(content.tag)\(content.attributes.map { " \($0.key.value)=\"\($0.value)\"" }
      .joined(separator: ""))>\(content.innerHTML != nil ? "\(content.innerHTML!)" : "")\(!content
      .children
      .isEmpty ? "\n" : "")\(content.children.map(\.description).joined(separator: "\n"))\(!content
      .children
      .isEmpty ? "\n" : "")</\(content.tag)>
    """
  }
}

@_spi(TokamakStaticHTML)
public protocol HTMLConvertible {
  var tag: String { get }
  var namespace: String? { get }
  func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String]
  var innerHTML: String? { get }
  func primitiveVisitor<V: ViewVisitor>(useDynamicLayout: Bool) -> ((V) -> ())?
}

public extension HTMLConvertible {
  @_spi(TokamakStaticHTML)
  var namespace: String? { nil }
  @_spi(TokamakStaticHTML)
  var innerHTML: String? { nil }
  func primitiveVisitor<V: ViewVisitor>(useDynamicLayout: Bool) -> ((V) -> ())? {
    nil
  }
}

@_spi(TokamakStaticHTML)
extension VStack: HTMLConvertible {
  @_spi(TokamakStaticHTML)
  public var tag: String { "div" }

  @_spi(TokamakStaticHTML)
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    guard !useDynamicLayout else { return [:] }
    let spacing = _VStackProxy(self).spacing
    return [
      "style": """
      justify-items: \(alignment.cssValue);
      \(hasSpacer ? "height: 100%;" : "")
      \(fillCrossAxis ? "width: 100%;" : "")
      \(spacing != defaultStackSpacing ? "--tokamak-stack-gap: \(spacing)px;" : "")
      """,
      "class": "_tokamak-stack _tokamak-vstack",
    ]
  }
}

@_spi(TokamakStaticHTML)
extension HStack: HTMLConvertible {
  @_spi(TokamakStaticHTML)
  public var tag: String { "div" }

  @_spi(TokamakStaticHTML)
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    guard !useDynamicLayout else { return [:] }
    let spacing = _HStackProxy(self).spacing
    return [
      "style": """
      align-items: \(alignment.cssValue);
      \(hasSpacer ? "width: 100%;" : "")
      \(fillCrossAxis ? "height: 100%;" : "")
      \(spacing != defaultStackSpacing ? "--tokamak-stack-gap: \(spacing)px;" : "")
      """,
      "class": "_tokamak-stack _tokamak-hstack",
    ]
  }
}

@_spi(TokamakCore)
extension LayoutView: HTMLConvertible {
  public var tag: String { "div" }
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    [:]
  }
}

public struct StaticHTMLFiberRenderer: FiberRenderer {
  public let rootElement: HTMLElement
  public let defaultEnvironment: EnvironmentValues
  public let sceneSize: CurrentValueSubject<CGSize, Never>
  public let useDynamicLayout: Bool

  public init() {
    self.init(useDynamicLayout: false, sceneSize: .zero)
  }

  /// An internal initializer used for testing dynamic layout with the `StaticHTMLFiberRenderer`.
  /// Normal use cases for dynamic layout require `TokamakDOM`.
  @_spi(TokamakStaticHTML)
  public init(useDynamicLayout: Bool, sceneSize: CGSize) {
    self.useDynamicLayout = useDynamicLayout
    self.sceneSize = .init(sceneSize)
    rootElement = .init(
      tag: "body", attributes: ["style": "margin: 0;"], innerHTML: nil, children: []
    )
    var environment = EnvironmentValues()
    environment[_ColorSchemeKey.self] = .light
    defaultEnvironment = environment
  }

  public static func isPrimitive<V>(_ view: V) -> Bool where V: View {
    !(view is AnyOptional) && view is HTMLConvertible
  }

  public func visitPrimitiveChildren<Primitive, Visitor>(
    _ view: Primitive
  ) -> ViewVisitorF<Visitor>? where Primitive: View, Visitor: ViewVisitor {
    guard let primitive = view as? HTMLConvertible else { return nil }
    return primitive.primitiveVisitor(useDynamicLayout: useDynamicLayout)
  }

  public func commit(_ mutations: [Mutation<Self>]) {
    for mutation in mutations {
      switch mutation {
      case let .insert(element, parent, index):
        parent.content.children.insert(element, at: index)
      case let .remove(element, parent):
        parent?.content.children.removeAll(where: { $0 === element })
      case let .replace(parent, previous, replacement):
        guard let index = parent.content.children.firstIndex(where: { $0 === previous })
        else { continue }
        parent.content.children[index] = replacement
      case let .update(previous, newContent, _):
        previous.update(with: newContent)
      case let .layout(element, data):
        element.content.attributes["style", default: ""] += """
        position: absolute;
        left: \(data.origin.x)px;
        top: \(data.origin.y)px;
        width: \(data.dimensions.width)px;
        height: \(data.dimensions.height)px;
        """
      }
    }
  }

  public func measureText(
    _ text: Text,
    proposal: ProposedViewSize,
    in environment: EnvironmentValues
  ) -> CGSize {
    .zero
  }

  public func measureImage(
    _ image: Image,
    proposal: ProposedViewSize,
    in environment: EnvironmentValues
  ) -> CGSize {
    .zero
  }

  public func render<A: App>(_ app: A) -> String {
    _ = FiberReconciler(self, app)
    return """
    <!doctype html>
    <html>
    \(rootElement.description)
    </html>
    """
  }

  public func render<V: View>(_ view: V) -> String {
    _ = FiberReconciler(self, view)
    return """
    <!doctype html>
    <html>
    \(rootElement.description)
    </html>
    """
  }

  public func schedule(_ action: @escaping () -> ()) {
    action()
  }
}
