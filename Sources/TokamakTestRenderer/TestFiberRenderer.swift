// Copyright 2021 Tokamak contributors
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
//  Created by Carson Katri on 4/5/22.
//

import Foundation
import OpenCombineShim
@_spi(TokamakCore) import TokamakCore

public protocol TestFiberPrimitive {
  var tag: String { get }
  var attributes: [String: Any] { get }
}

public extension TestFiberPrimitive {
  var tag: String { String(String(reflecting: Self.self).split(separator: "<")[0]) }
}

extension VStack: TestFiberPrimitive {
  public var attributes: [String: Any] {
    ["spacing": _VStackProxy(self).spacing, "alignment": alignment]
  }
}

extension HStack: TestFiberPrimitive {
  public var attributes: [String: Any] {
    ["spacing": _HStackProxy(self).spacing, "alignment": alignment]
  }
}

extension Text: TestFiberPrimitive {
  public var attributes: [String: Any] {
    let proxy = _TextProxy(self)
    return ["content": proxy.storage.rawText, "modifiers": proxy.modifiers]
  }
}

extension _Button: TestFiberPrimitive {
  public var attributes: [String: Any] {
    ["action": action, "role": role as Any]
  }
}

extension _PrimitiveButtonStyleBody: TestFiberPrimitive {
  public var attributes: [String: Any] {
    ["size": controlSize, "role": role as Any]
  }
}

extension _FrameLayout: TestFiberPrimitive {
  public var attributes: [String: Any] {
    ["width": width as Any, "height": height as Any]
  }
}

extension ModifiedContent: TestFiberPrimitive where Modifier: TestFiberPrimitive {
  public var attributes: [String: Any] {
    modifier.attributes
  }
}

public final class TestFiberElement: FiberElement, CustomStringConvertible {
  public struct Content: FiberElementContent, Equatable {
    let renderedValue: String
    let closingTag: String

    init(
      renderedValue: String,
      closingTag: String
    ) {
      self.renderedValue = renderedValue
      self.closingTag = closingTag
    }

    public init<V>(from primitiveView: V, useDynamicLayout: Bool) where V: View {
      guard let primitiveView = primitiveView as? TestFiberPrimitive else { fatalError() }
      let attributes = primitiveView.attributes
        .sorted(by: { $0.key < $1.key })
        .map { "\($0.key)=\"\(String(describing: $0.value))\"" }
        .joined(separator: " ")
      renderedValue =
        "<\(primitiveView.tag) \(attributes)>"
      closingTag = "</\(primitiveView.tag)>"
    }
  }

  public var content: Content
  public var children: [TestFiberElement]
  public var geometry: ViewGeometry?

  public init(from content: Content) {
    self.content = content
    children = []
  }

  public var description: String {
    """
    \(content.renderedValue)
    \(children.map { "  \($0.description)" }.joined(separator: "\n"))
    \(content.closingTag)
    """
  }

  public init(renderedValue: String, closingTag: String) {
    content = .init(renderedValue: renderedValue, closingTag: closingTag)
    children = []
  }

  public func update(with content: Content) {
    self.content = content
  }

  public static var root: Self { .init(renderedValue: "<root>", closingTag: "</root>") }
}

public struct TestFiberRenderer: FiberRenderer {
  public let sceneSize: CurrentValueSubject<CGSize, Never>
  public let useDynamicLayout: Bool

  public func measureText(
    _ text: Text,
    proposal: ProposedViewSize,
    in environment: EnvironmentValues
  ) -> CGSize {
    proposal.replacingUnspecifiedDimensions()
  }

  public func measureImage(
    _ image: Image,
    proposal: ProposedViewSize,
    in environment: EnvironmentValues
  ) -> CGSize {
    proposal.replacingUnspecifiedDimensions()
  }

  public typealias ElementType = TestFiberElement

  public let rootElement: ElementType

  public init(_ rootElement: ElementType, size: CGSize, useDynamicLayout: Bool = false) {
    self.rootElement = rootElement
    sceneSize = .init(size)
    self.useDynamicLayout = useDynamicLayout
  }

  public static func isPrimitive<V>(_ view: V) -> Bool where V: View {
    view is TestFiberPrimitive
  }

  public func commit(_ mutations: [Mutation<Self>]) {
    for mutation in mutations {
      switch mutation {
      case let .insert(element, parent, index):
        parent.children.insert(element, at: index)
      case let .remove(element, parent):
        parent?.children.removeAll(where: { $0 === element })
      case let .replace(parent, previous, replacement):
        guard let index = parent.children.firstIndex(where: { $0 === previous })
        else { continue }
        parent.children[index] = replacement
      case let .layout(element, geometry):
        element.geometry = geometry
      case let .update(previous, newContent, _):
        previous.update(with: newContent)
      }
    }
  }

  public func schedule(_ action: @escaping () -> ()) {
    action()
  }
}
