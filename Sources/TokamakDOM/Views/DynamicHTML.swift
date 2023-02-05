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
//  Created by Carson Katri on 7/31/20.
//

import JavaScriptKit
import TokamakCore

@_spi(TokamakStaticHTML)
import TokamakStaticHTML

public typealias HTML = TokamakStaticHTML.HTML

public typealias Listener = (JSObject) -> ()

protocol AnyDynamicHTML: AnyHTML {
  var listeners: [String: Listener] { get }
}

public struct DynamicHTML<Content>: View, AnyDynamicHTML {
  public let tag: String
  public let attributes: [HTMLAttribute: String]
  public let listeners: [String: Listener]
  let content: Content
  let visitContent: (ViewVisitor) -> ()

  fileprivate let cachedInnerHTML: String?

  public func innerHTML(shouldSortAttributes: Bool) -> String? {
    cachedInnerHTML
  }

  @_spi(TokamakCore)
  public var body: Never {
    neverBody("HTML")
  }

  public func _visitChildren<V>(_ visitor: V) where V: ViewVisitor {
    visitContent(visitor)
  }
}

public extension DynamicHTML where Content: StringProtocol {
  init(
    _ tag: String,
    _ attributes: [HTMLAttribute: String] = [:],
    listeners: [String: Listener] = [:],
    content: Content
  ) {
    self.tag = tag
    self.attributes = attributes
    self.listeners = listeners
    self.content = content
    cachedInnerHTML = String(content)
    visitContent = { _ in }
  }
}

extension DynamicHTML: ParentView where Content: View {
  public init(
    _ tag: String,
    _ attributes: [HTMLAttribute: String] = [:],
    listeners: [String: Listener] = [:],
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.tag = tag
    self.attributes = attributes
    self.listeners = listeners
    self.content = content()
    cachedInnerHTML = nil
    visitContent = { $0.visit(content()) }
  }

  @_spi(TokamakCore)
  public var children: [AnyView] {
    [AnyView(content)]
  }
}

public extension DynamicHTML where Content == EmptyView {
  init(
    _ tag: String,
    _ attributes: [HTMLAttribute: String] = [:],
    listeners: [String: Listener] = [:]
  ) {
    self = DynamicHTML(tag, attributes, listeners: listeners) { EmptyView() }
  }
}

@_spi(TokamakStaticHTML)
extension DynamicHTML: HTMLConvertible {
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    attributes
  }
}
