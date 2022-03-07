//
//  File.swift
//
//
//  Created by Carson Katri on 2/6/22.
//

import Foundation
@_spi(TokamakCore) import TokamakCore

public final class HTMLElement: Element, CustomStringConvertible {
  public struct Data: ElementData, Equatable {
    public static func == (lhs: HTMLElement.Data, rhs: HTMLElement.Data) -> Bool {
      lhs.tag == rhs.tag
        && lhs.attributes == rhs.attributes
        && lhs.innerHTML == rhs.innerHTML
        && lhs.children.map(\.data) == rhs.children.map(\.data)
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
  }

  public var data: Data

  public init(from data: Data) {
    self.data = data
  }

  public init(
    tag: String,
    attributes: [HTMLAttribute: String],
    innerHTML: String?,
    children: [HTMLElement]
  ) {
    data = .init(
      tag: tag,
      attributes: attributes,
      innerHTML: innerHTML,
      children: children
    )
  }

  public func update(with data: Data) {
    self.data = data
  }

  public var description: String {
    """
    <\(data.tag)\(data.attributes.map { " \($0.key.value)=\"\($0.value)\"" }
      .joined(separator: ""))>\(data.innerHTML != nil ? "\(data.innerHTML!)" : "")\(!data.children
      .isEmpty ? "\n" : "")\(data.children.map(\.description).joined(separator: "\n"))\(!data
      .children
      .isEmpty ? "\n" : "")</\(data.tag)>
    """
  }
}

@_spi(TokamakStaticHTML) public protocol HTMLConvertible {
  var tag: String { get }
  var attributes: [HTMLAttribute: String] { get }
  var innerHTML: String? { get }
}

public extension HTMLConvertible {
  @_spi(TokamakStaticHTML) var innerHTML: String? { nil }
}

@_spi(TokamakStaticHTML) extension Text: HTMLConvertible {
  @_spi(TokamakStaticHTML) public var innerHTML: String? {
    _TextProxy(self).rawText
  }
}

@_spi(TokamakStaticHTML) extension VStack: HTMLConvertible {
  @_spi(TokamakStaticHTML) public var tag: String { "div" }
  @_spi(TokamakStaticHTML) public var attributes: [HTMLAttribute: String] {
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

@_spi(TokamakStaticHTML) extension HStack: HTMLConvertible {
  @_spi(TokamakStaticHTML) public var tag: String { "div" }
  @_spi(TokamakStaticHTML) public var attributes: [HTMLAttribute: String] {
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

@_spi(TokamakCore) public struct StaticHTMLFiberRenderer: FiberRenderer {
  public let rootElement: HTMLElement
  public let defaultEnvironment: EnvironmentValues
  public var sceneSize: CGSize { .zero }

  init() {
    rootElement = .init(tag: "body", attributes: [:], innerHTML: nil, children: [])
    var environment = EnvironmentValues()
    environment[_ColorSchemeKey.self] = .light
    defaultEnvironment = environment
  }

  public static func isPrimitive<V>(_ view: V) -> Bool where V: View {
    view is HTMLConvertible
  }

  public func commit(_ mutations: [Mutation<Self>]) {
    for mutation in mutations {
      switch mutation {
      case let .insert(element, parent, index):
        parent.data.children.insert(element, at: index)
      case let .remove(element, parent):
        parent?.data.children.removeAll(where: { $0 === element })
      case let .replace(parent, previous, replacement):
        guard let index = parent.data.children.firstIndex(where: { $0 === previous })
        else { continue }
        parent.data.children[index] = replacement
      case let .update(previous, newData):
        previous.update(with: newData)
      case let .layout(element, data):
        print("Received layout message \(data) for \(element)")
      }
    }
  }

  public func measureText(_ text: Text, proposedSize: CGSize,
                          in environment: EnvironmentValues) -> CGSize
  {
    .zero
  }
}
