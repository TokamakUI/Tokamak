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

public typealias Listener = (JSObjectRef) -> ()

public typealias View = TokamakCore.View
public typealias AnyView = TokamakCore.AnyView
public typealias EmptyView = TokamakCore.EmptyView
public typealias State = TokamakCore.State

protocol AnyHTML {
  var innerHTML: String? { get }
  var tag: String { get }
  var attributes: [String: String] { get }
  var listeners: [String: Listener] { get }
}

extension AnyHTML {
  public var outerHTML: String {
    """
    <\(tag)\(attributes.isEmpty ? "" : " ")\
    \(attributes.map { #"\#($0)="\#($1)""# }.joined(separator: " "))>\
    \(innerHTML ?? "")\
    </\(tag)>
    """
  }

  func update(dom: JSObjectRef) {
    // FIXME: handle attributes and listeners here
    guard let innerHTML = innerHTML else { return }
    dom.innerHTML = .string(innerHTML)
  }
}

public struct HTML<Content>: View, AnyHTML where Content: View {
  let tag: String
  let attributes: [String: String]
  let listeners: [String: Listener]
  let content: Content

  public init(
    _ tag: String,
    _ attributes: [String: String] = [:],
    listeners: [String: Listener] = [:],
    @ViewBuilder content: () -> Content
  ) {
    self.tag = tag
    self.attributes = attributes
    self.listeners = listeners
    self.content = content()
  }

  var innerHTML: String? { nil }

  public var body: Never {
    neverBody("HTML")
  }
}

extension HTML where Content == EmptyView {
  public init(
    _ tag: String,
    _ attributes: [String: String] = [:],
    listeners: [String: Listener] = [:]
  ) {
    self.tag = tag
    self.attributes = attributes
    self.listeners = listeners
    content = EmptyView()
  }
}

extension HTML: ParentView {
  public var children: [AnyView] {
    [AnyView(content)]
  }
}

protocol StylesConvertible {
  var styles: [String: String] { get }
}

extension Dictionary {
  var inlineStyles: String {
    map { "\($0.0): \($0.1);" }
      .joined(separator: " ")
  }
}
