//
//  File.swift
//
//
//  Created by Carson Katri on 7/31/20.
//

import JavaScriptKit
import TokamakCore
import TokamakStaticHTML

public typealias Listener = (JSObjectRef) -> ()

protocol AnyDynamicHTML: AnyHTML {
  var listeners: [String: Listener] { get }
}

public struct DynamicHTML<Content>: View, AnyDynamicHTML where Content: View {
  public let tag: String
  public let attributes: [String: String]
  public let listeners: [String: Listener]
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

  public var innerHTML: String? { nil }

  public var body: Never {
    neverBody("HTML")
  }
}

extension DynamicHTML where Content == EmptyView {
  public init(
    _ tag: String,
    _ attributes: [String: String] = [:],
    listeners: [String: Listener] = [:]
  ) {
    self = DynamicHTML(tag, attributes, listeners: listeners) { EmptyView() }
  }
}

extension DynamicHTML: ParentView {
  public var children: [AnyView] {
    [AnyView(content)]
  }
}
