//
//  File.swift
//
//
//  Created by Carson Katri on 2/6/22.
//

import TokamakCore

public final class HTMLElement: Element, CustomStringConvertible {
  public static func == (lhs: HTMLElement, rhs: HTMLElement) -> Bool {
    lhs.tag == rhs.tag && lhs.attributes == rhs.attributes
  }

  var tag: String
  var attributes: [HTMLAttribute: String]
  var innerHTML: String?
  var children: [HTMLElement] = []

  public init<V>(from primitiveView: V) where V: View {
    guard let primitiveView = primitiveView as? HTMLConvertible else { fatalError() }
    tag = primitiveView.tag
    attributes = primitiveView.attributes
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

  public var description: String {
    """
    <\(tag)\(attributes.map { " \($0.key.value)=\"\($0.value)\"" }
      .joined(separator: ""))>\(innerHTML != nil ? "\(innerHTML!)" : "")\(!children
      .isEmpty ? "\n" : "")\(children.map(\.description).joined(separator: "\n"))\(!children
      .isEmpty ? "\n" : "")</\(tag)>
    """
  }
}

protocol HTMLConvertible {
  var tag: String { get }
  var attributes: [HTMLAttribute: String] { get }
  var innerHTML: String? { get }
}

extension Text: HTMLConvertible {
  var innerHTML: String? {
    _TextProxy(self).rawText
  }
}

extension VStack: HTMLConvertible {
  var tag: String { "div" }
  var attributes: [HTMLAttribute: String] {
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

  var innerHTML: String? { nil }
}

public struct StaticHTMLGraphRenderer: GraphRenderer {
  public let rootElement: HTMLElement
  public let defaultEnvironment: EnvironmentValues

  init() {
    rootElement = .init(tag: "body", attributes: [:], innerHTML: nil, children: [])
    var environment = EnvironmentValues()
    environment[_ColorSchemeKey.self] = .light
    defaultEnvironment = environment
  }

  public static func isPrimitive<V>(_ view: V) -> Bool where V: View {
    view is HTMLConvertible
  }

  public func commit(_ mutations: [RenderableMutation<Self>]) {
    for mutation in mutations {
      switch mutation {
      case let .insert(element, parent, sibling):
        if let index = parent.children.firstIndex(where: { $0 === sibling }) {
          parent.children.insert(element, at: index + 1)
        } else {
          parent.children.insert(element, at: 0)
        }
      case let .remove(element, parent):
        parent?.children.removeAll(where: { $0 === element })
      case let .replace(parent, previous, replacement):
        guard let index = parent.children.firstIndex(where: { $0 === previous }) else { continue }
        parent.children[index] = replacement
      case let .update(previous, newElement):
        previous.tag = newElement.tag
        previous.attributes = newElement.attributes
      }
    }
  }
}
