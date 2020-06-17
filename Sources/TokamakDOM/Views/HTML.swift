//
//  Created by Max Desiatov on 11/04/2020.
//

import JavaScriptKit
import Tokamak

public typealias Listener = (JSObjectRef) -> ()

protocol AnyHTML: CustomStringConvertible {
  var listeners: [String: Listener] { get }
}

public struct HTML<Content>: View, AnyHTML where Content: View {
  let tag: String
  let attributes: [String: String]
  let listeners: [String: Listener]
  let content: Content

  public init(
    tag: String,
    attributes: [String: String] = [:],
    listeners: [String: Listener] = [:],
    @ViewBuilder content: () -> Content
  ) {
    self.tag = tag
    self.attributes = attributes
    self.listeners = listeners
    self.content = content()
  }

  public var description: String {
    "<\(tag) \(attributes.map { #"\#($0)="\#($1)""# }.joined(separator: " "))></\(tag)>"
  }
}

extension HTML where Content == EmptyView {
  public init(
    tag: String,
    attributes: [String: String] = [:],
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
