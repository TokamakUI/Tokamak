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

import TokamakCore

/** Represents an attribute of an HTML tag. To consume updates from updated attributes, the DOM
 renderer needs to know whether the attribute should be assigned via a DOM element property or the
 [`setAttribute`](https://developer.mozilla.org/en-US/docs/Web/API/Element/setAttribute) function.
 The `isUpdatedAsProperty` flag is used to disambiguate between these two cases.
 */
public struct HTMLAttribute: Hashable {
  public let value: String
  public let isUpdatedAsProperty: Bool

  public init(_ value: String, isUpdatedAsProperty: Bool) {
    self.value = value
    self.isUpdatedAsProperty = isUpdatedAsProperty
  }

  public static let value = HTMLAttribute("value", isUpdatedAsProperty: true)
}

extension HTMLAttribute: CustomStringConvertible {
  public var description: String { value }
}

extension HTMLAttribute: ExpressibleByStringLiteral {
  public init(stringLiteral: String) {
    self.init(stringLiteral, isUpdatedAsProperty: false)
  }
}

public protocol AnyHTML {
  var innerHTML: String? { get }
  var tag: String { get }
  var attributes: [HTMLAttribute: String] { get }
}

public extension AnyHTML {
  var outerHTML: String {
    """
    <\(tag)\(attributes.isEmpty ? "" : " ")\
    \(attributes.map { #"\#($0)="\#($1)""# }.joined(separator: " "))>\
    \(innerHTML ?? "")\
    </\(tag)>
    """
  }
}

public struct HTML<Content>: View, AnyHTML {
  public let tag: String
  public let attributes: [HTMLAttribute: String]
  let content: Content

  public let innerHTML: String?

  public var body: Never {
    neverBody("HTML")
  }
}

public extension HTML where Content: StringProtocol {
  init(
    _ tag: String,
    _ attributes: [HTMLAttribute: String] = [:],
    content: Content
  ) {
    self.tag = tag
    self.attributes = attributes
    self.content = content
    innerHTML = String(content)
  }
}

extension HTML: ParentView where Content: View {
  public init(
    _ tag: String,
    _ attributes: [HTMLAttribute: String] = [:],
    @ViewBuilder content: () -> Content
  ) {
    self.tag = tag
    self.attributes = attributes
    self.content = content()
    innerHTML = nil
  }

  public var children: [AnyView] {
    [AnyView(content)]
  }
}

public extension HTML where Content == EmptyView {
  init(
    _ tag: String,
    _ attributes: [HTMLAttribute: String] = [:]
  ) {
    self = HTML(tag, attributes) { EmptyView() }
  }
}

public protocol StylesConvertible {
  var styles: [String: String] { get }
}

public extension Dictionary {
  var inlineStyles: String {
    map { "\($0.0): \($0.1);" }
      .joined(separator: " ")
  }
}
