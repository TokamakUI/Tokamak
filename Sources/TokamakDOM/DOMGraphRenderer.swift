//
//  File.swift
//
//
//  Created by Carson Katri on 2/7/22.
//

import JavaScriptKit
@_spi(TokamakCore) import TokamakCore
@_spi(TokamakStaticHTML) import TokamakStaticHTML

public final class DOMElement: Element {
  public static func == (lhs: DOMElement, rhs: DOMElement) -> Bool {
    lhs.tag == rhs.tag && lhs.attributes == rhs.attributes && lhs.innerHTML == rhs.innerHTML
  }

  var reference: JSObject?
  var tag: String
  var attributes: [HTMLAttribute: String]
  var innerHTML: String?
  var listeners: [String: Listener] = [:]

  public init<V>(from primitiveView: V) where V: View {
    guard let primitiveView = primitiveView as? HTMLConvertible else { fatalError() }
    tag = primitiveView.tag
    attributes = primitiveView.attributes
    innerHTML = primitiveView.innerHTML

    if let primitiveView = primitiveView as? DOMNodeConvertible {
      listeners = primitiveView.listeners
    }
  }

  public init(
    reference: JSObject?,
    tag: String,
    attributes: [HTMLAttribute: String],
    innerHTML: String?,
    listeners: [String: Listener]
  ) {
    self.reference = reference
    self.tag = tag
    self.attributes = attributes
    self.innerHTML = innerHTML
    self.listeners = listeners
  }
}

protocol DOMNodeConvertible: HTMLConvertible {
  var listeners: [String: Listener] { get }
}

public struct DOMGraphRenderer: GraphRenderer {
  public let rootElement: DOMElement
  private let jsCommit: JSFunction

  public var defaultEnvironment: EnvironmentValues {
    var environment = EnvironmentValues()
    environment[_ColorSchemeKey.self] = .light
    return environment
  }

  public init(_ rootSelector: String) {
    guard let Tokamak = JSObject.global.Tokamak.object else {
      fatalError("""
      Tokamak is not detected in the page's scripts. Ensure you included the Tokamak script in your site.
      """)
    }
    jsCommit = Tokamak.commit.function!
    guard let reference = document.querySelector!(rootSelector).object else {
      fatalError("""
      The root element with selector '\(rootSelector)' could not be found. \
      Ensure this element exists in your site's index.html file.
      """)
    }
    rootElement = .init(
      reference: reference,
      tag: "",
      attributes: [:],
      innerHTML: nil,
      listeners: [:]
    )
    Tokamak.root = .object(reference)
  }

  public static func isPrimitive<V>(_ view: V) -> Bool where V: View {
    view is HTMLConvertible || view is DOMNodeConvertible
  }

  public func commit(_ mutations: [RenderableMutation<Self>]) {
    jsCommit(mutations.map { $0.object() })
  }
}

extension RenderableMutation where Renderer == DOMGraphRenderer {
  func object() -> [String: ConvertibleToJSValue] {
    switch self {
    case let .insert(element, parent, index):
      return [
        "operation": 0,
        "element": element.data,
        "parent": parent.lazyReference,
        "index": index,
      ]
    case let .remove(element, parent):
      return [
        "operation": 1,
        "element": element.reference,
        "parent": parent?.lazyReference,
      ]
    case let .replace(parent, previous, replacement):
      return [
        "operation": 2,
        "parent": parent.lazyReference,
        "element": previous.lazyReference,
        "replacement": replacement.data,
      ]
    case let .update(previous, newElement):
      return [
        "operation": 3,
        "previous": previous.reference,
        "updates": newElement.data,
      ]
    }
  }
}

extension DOMElement {
  var data: [String: ConvertibleToJSValue] {
    [
      "tag": reference ?? tag,
      "attributes": attributes.map {
        [
          "name": $0.key.value,
          "property": $0.key.isUpdatedAsProperty,
          "value": $0.value,
        ]
      },
      "innerHTML": innerHTML,
      "listeners": listeners.mapValues { listener in
        JSClosure {
          listener($0[0].object!)
          return .undefined
        }
      },
      "bind": JSOneshotClosure { [weak self] in
        self?.reference = $0[0].object!
        return .undefined
      },
    ]
  }

  var lazyReference: JSClosure {
    JSClosure { _ in
      guard let reference = self.reference else { return .undefined }
      return .object(reference)
    }
  }
}

extension _PrimitiveButtonStyleBody: DOMNodeConvertible {
  public var tag: String { "button" }
  public var attributes: [HTMLAttribute: String] { [:] }
  var listeners: [String: Listener] {
    ["pointerup": { _ in self.action() }]
  }
}
