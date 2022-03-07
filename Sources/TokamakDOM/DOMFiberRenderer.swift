//
//  File.swift
//
//
//  Created by Carson Katri on 2/7/22.
//

import Foundation
import JavaScriptKit
@_spi(TokamakCore) import TokamakCore
@_spi(TokamakStaticHTML) import TokamakStaticHTML

public final class DOMElement: Element {
  var reference: JSObject?

  public struct Data: ElementData {
    let tag: String
    let attributes: [HTMLAttribute: String]
    let innerHTML: String?
    let listeners: [String: Listener]
    let debugData: [String: ConvertibleToJSValue]

    public static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.tag == rhs.tag && lhs.attributes == rhs.attributes && lhs.innerHTML == rhs.innerHTML
    }
  }

  public var data: Data

  public init(from data: Data) {
    self.data = data
  }

  public func update(with data: Data) {
    self.data = data
  }
}

public extension DOMElement.Data {
  init<V>(from primitiveView: V) where V: View {
    guard let primitiveView = primitiveView as? HTMLConvertible else { fatalError() }
    tag = primitiveView.tag
    attributes = primitiveView.attributes
    innerHTML = primitiveView.innerHTML

    if let primitiveView = primitiveView as? DOMNodeConvertible {
      listeners = primitiveView.listeners
    } else {
      listeners = [:]
    }

    debugData = [
      "view": String(reflecting: V.self),
    ]
  }
}

protocol DOMNodeConvertible: HTMLConvertible {
  var listeners: [String: Listener] { get }
}

public struct DOMFiberRenderer: FiberRenderer {
  public let rootElement: DOMElement
  private let jsCommit: JSFunction
  private let jsMeasureText: JSFunction

  public var sceneSize: CGSize {
    .init(width: body.clientWidth.number!, height: body.clientHeight.number!)
  }

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
    jsMeasureText = Tokamak.measureText.function!
    guard let reference = document.querySelector!(rootSelector).object else {
      fatalError("""
      The root element with selector '\(rootSelector)' could not be found. \
      Ensure this element exists in your site's index.html file.
      """)
    }
    rootElement = .init(
      from: .init(
        tag: "",
        attributes: [:],
        innerHTML: nil,
        listeners: [:],
        debugData: ["view": "root"]
      )
    )
    rootElement.reference = reference
    Tokamak.initRoot.function!(reference)
  }

  public static func isPrimitive<V>(_ view: V) -> Bool where V: View {
    view is HTMLConvertible || view is DOMNodeConvertible
  }

  public func commit(_ mutations: [Mutation<Self>]) {
    jsCommit(mutations.map { $0.object() })
  }

  public func measureText(_ text: Text, proposedSize: CGSize,
                          in environment: EnvironmentValues) -> CGSize
  {
    // FIXME: Use text styles.
    let dimensions = jsMeasureText(
      text.innerHTML ?? "",
      [
        "width": Double(proposedSize.width),
        "height": Double(proposedSize.height),
      ]
    )
    return .init(
      width: dimensions.width.number ?? 0,
      height: dimensions.height.number ?? 0
    )
  }
}

extension Mutation where Renderer == DOMFiberRenderer {
  func object() -> [String: ConvertibleToJSValue] {
    switch self {
    case let .insert(element, parent, index):
      return [
        "operation": 0,
        "element": element.data.encoded
          .merging(["bind": element.bindClosure], uniquingKeysWith: { $1 }),
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
        "replacement": replacement.data.encoded,
      ]
    case let .update(previous, newElement):
      previous.update(with: newElement)
      return [
        "operation": 3,
        "previous": previous.reference,
        "updates": newElement.encoded
          .merging(["bind": previous.bindClosure], uniquingKeysWith: { $1 }),
      ]
    case let .layout(element, geometry):
      return [
        "operation": 4,
        "element": element.lazyReference,
        "geometry": geometry.encoded,
      ]
    }
  }
}

extension DOMElement {
  var bindClosure: ConvertibleToJSValue {
    JSOneshotClosure { [weak self] in
      self?.reference = $0[0].object!
      return .undefined
    }
  }

  var lazyReference: JSClosure {
    JSClosure { _ in
      guard let reference = self.reference else { return .undefined }
      return .object(reference)
    }
  }
}

extension DOMElement.Data {
  var encoded: [String: ConvertibleToJSValue] {
    [
      "tag": tag,
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
      "debugData": debugData,
    ]
  }
}

extension ViewGeometry {
  var encoded: [String: ConvertibleToJSValue] {
    [
      "x": Double(origin.x),
      "y": Double(origin.y),
      "width": Double(dimensions.width),
      "height": Double(dimensions.height),
    ]
  }
}

extension _PrimitiveButtonStyleBody: DOMNodeConvertible {
  public var tag: String { "button" }
  public var attributes: [HTMLAttribute: String] { [:] }
  var listeners: [String: Listener] {
    ["pointerup": { _ in self.action() }]
  }
}
