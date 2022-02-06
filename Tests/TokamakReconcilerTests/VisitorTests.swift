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
//  Created by Carson Katri on 2/3/22.
//

import XCTest

@_spi(TokamakCore) @testable import TokamakCore

private struct TestView: View {
  struct Counter: View {
    @State private var count = 0

    var body: some View {
      VStack {
        Text("\(count)")
        HStack {
          Button("Decrement") {
            count -= 1
          }
          Button("Increment") {
            count += 1
          }
        }
      }
    }
  }

  public var body: some View {
    Counter()
  }
}

protocol TestPrimitive {
  var tag: String { get }
  var attributes: [String: Any] { get }
}

extension TestPrimitive {
  var tag: String { String(String(reflecting: Self.self).split(separator: "<")[0]) }
}

extension VStack: TestPrimitive {
  var attributes: [String: Any] {
    ["spacing": spacing, "alignment": alignment]
  }
}

extension HStack: TestPrimitive {
  var attributes: [String: Any] {
    ["spacing": spacing, "alignment": alignment]
  }
}

extension Text: TestPrimitive {
  var attributes: [String: Any] {
    ["content": storage.rawText, "modifiers": modifiers]
  }
}

extension _Button: TestPrimitive {
  var attributes: [String: Any] {
    ["action": action, "role": role as Any]
  }
}

extension _PrimitiveButtonStyleBody: TestPrimitive {
  var attributes: [String: Any] {
    ["size": controlSize, "role": role as Any]
  }
}

final class TestElement: Element, CustomStringConvertible {
  static func == (lhs: TestElement, rhs: TestElement) -> Bool {
    lhs.renderedValue == rhs.renderedValue && lhs.closingTag == rhs.closingTag
  }

  var renderedValue: String
  var closingTag: String

  init<V>(from primitiveView: V) where V: View {
    guard let primitiveView = primitiveView as? TestPrimitive else { fatalError() }
    renderedValue =
      "<\(primitiveView.tag) \(primitiveView.attributes.sorted(by: { $0.key < $1.key }).map { "\($0.key)=\"\(String(describing: $0.value))\"" }.joined(separator: " "))>"
    closingTag = "</\(primitiveView.tag)>"
  }

  var description: String {
    "\(renderedValue)\(closingTag)"
  }
}

struct TestRenderer: GraphRenderer {
  typealias ElementType = TestElement

  static func isPrimitive<V>(_ view: V) -> Bool where V: View {
    view is TestPrimitive
  }

  func commit(_ mutations: [RenderableMutation<TestRenderer>]) {
    for mutation in mutations {
      switch mutation {
      case let .insert(element, parent, sibling):
        print("Insert \(element) after \(sibling as Any) in \(parent)")
      case let .remove(element, parent):
        print("Remove \(element) from \(parent as Any)")
      case let .replace(parent, previous, replacement):
        print("Replace \(previous) with \(replacement) in \(parent)")
      case let .update(previous, newElement):
        print("Update \(previous) with \(newElement)")
      }
    }
  }
}

final class VisitorTests: XCTestCase {
  func testRenderer() {
    let reconciler = TestRenderer().render(TestView())
    let decrement = (
      reconciler.tree
        .findView(id: .structural(index: 0))? // TestView
        .findView(id: .structural(index: 0))? // Counter
        .findView(id: .structural(index: 0))? // VStack
        .findView(id: .structural(index: 0))? // TupleView
        .findView(id: .structural(index: 1))? // HStack
        .findView(id: .structural(index: 0))? // TupleView
        .findView(id: .structural(index: 0))? // Increment Button
        .view as? Button<Text>
    )
    let increment = (
      reconciler.tree
        .findView(id: .structural(index: 0))? // TestView
        .findView(id: .structural(index: 0))? // Counter
        .findView(id: .structural(index: 0))? // VStack
        .findView(id: .structural(index: 0))? // TupleView
        .findView(id: .structural(index: 1))? // HStack
        .findView(id: .structural(index: 0))? // TupleView
        .findView(id: .structural(index: 1))? // Increment Button
        .view as? Button<Text>
    )
    increment?.action()
    let text = reconciler.tree
      .findView(id: .structural(index: 0))? // TestView
      .findView(id: .structural(index: 0))? // Counter
      .findView(id: .structural(index: 0))? // VStack
      .findView(id: .structural(index: 0))? // TupleView
      .findView(id: .structural(index: 0)) // Text
    XCTAssertEqual(
      text?.element?.description,
      "<TokamakCore.Text content=\"1\" modifiers=\"[]\"></TokamakCore.Text>"
    )
    increment?.action()
    XCTAssertEqual(
      text?.element?.description,
      "<TokamakCore.Text content=\"2\" modifiers=\"[]\"></TokamakCore.Text>"
    )
    decrement?.action()
    XCTAssertEqual(
      text?.element?.description,
      "<TokamakCore.Text content=\"1\" modifiers=\"[]\"></TokamakCore.Text>"
    )
  }
}
