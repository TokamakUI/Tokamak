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
          if count > 0 {
            Button("Decrement") {
              print("Decrement")
              count -= 1
            }
          }
          if count < 5 {
            Button("Increment") {
              print("Increment")
              if count + 1 >= 5 {
                print("Hit 5")
              }
              count += 1
            }
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
  struct Data: ElementData, Equatable {
    let renderedValue: String
    let closingTag: String

    init(
      renderedValue: String,
      closingTag: String
    ) {
      self.renderedValue = renderedValue
      self.closingTag = closingTag
    }

    init<V>(from primitiveView: V) where V: View {
      guard let primitiveView = primitiveView as? TestPrimitive else { fatalError() }
      renderedValue =
        "<\(primitiveView.tag) \(primitiveView.attributes.sorted(by: { $0.key < $1.key }).map { "\($0.key)=\"\(String(describing: $0.value))\"" }.joined(separator: " "))>"
      closingTag = "</\(primitiveView.tag)>"
    }
  }

  var data: Data

  init(from data: Data) {
    self.data = data
  }

  var description: String {
    "\(data.renderedValue)\(data.closingTag)"
  }

  init(renderedValue: String, closingTag: String) {
    data = .init(renderedValue: renderedValue, closingTag: closingTag)
  }

  func update(with data: Data) {
    self.data = data
  }

  static var root: Self { .init(renderedValue: "<root>", closingTag: "</root>") }
}

struct TestRenderer: GraphRenderer {
  typealias ElementType = TestElement

  let rootElement: TestElement

  init(_ rootElement: TestElement) {
    self.rootElement = rootElement
  }

  static func isPrimitive<V>(_ view: V) -> Bool where V: View {
    view is TestPrimitive
  }

  func commit(_ mutations: [Mutation<TestRenderer>]) {
    for mutation in mutations {
      switch mutation {
      case let .insert(element, parent, index):
        print("Insert \(element) at \(index) in \(parent)")
      case let .remove(element, parent):
        print("Remove \(element) from \(parent as Any)")
      case let .replace(parent, previous, replacement):
        print("Replace \(previous) with \(replacement) in \(parent)")
      case let .update(previous, newData):
        print("Update \(previous) with \(newData)")
        previous.update(with: newData)
        print(previous)
      }
    }
  }
}

final class VisitorTests: XCTestCase {
  func testRenderer() {
    let reconciler = TestRenderer(.root).render(TestView())
    func decrement() {
      (
        reconciler.current // ModifiedContent
          .child? // _ViewModifier_Content
          .child? // TestView
          .child? // Counter
          .child? // VStack
          .child? // TupleView
          .child?.sibling? // HStack
          .child? // TupleView
          .child? // Optional
          .child? // Button
          .view as? Button<Text>
      )?
        .action()
    }
    func increment() {
      (
        reconciler.current // ModifiedContent
          .child? // _ViewModifier_Content
          .child? // TestView
          .child? // Counter
          .child? // VStack
          .child? // TupleView
          .child? // Text
          .sibling? // HStack
          .child? // TupleView
          .child? // Optional
          .sibling? // Optional
          .child? // Button
          .view as? Button<Text>
      )?
        .action()
    }
    for i in 0..<5 {
      increment()
    }
    print(reconciler.current)
    decrement()
//    for i in 0..<5 {
//      increment()
//    }
//    print(reconciler.tree)
//    decrement()
//    print(reconciler.tree)

//    let decrement = (
//      reconciler.tree
//        .findView(id: .structural(index: 0))? // TestView
//        .findView(id: .structural(index: 0))? // Counter
//        .findView(id: .structural(index: 0))? // VStack
//        .findView(id: .structural(index: 0))? // TupleView
//        .findView(id: .structural(index: 1))? // HStack
//        .findView(id: .structural(index: 0))? // TupleView
//        .findView(id: .structural(index: 0))? // Increment Button
//        .view as? Button<Text>
//    )
//    let increment = (
//      reconciler.tree
//        .findView(id: .structural(index: 0))? // TestView
//        .findView(id: .structural(index: 0))? // Counter
//        .findView(id: .structural(index: 0))? // VStack
//        .findView(id: .structural(index: 0))? // TupleView
//        .findView(id: .structural(index: 1))? // HStack
//        .findView(id: .structural(index: 0))? // TupleView
//        .findView(id: .structural(index: 1))? // Increment Button
//        .view as? Button<Text>
//    )
//    increment?.action()
//    let text = reconciler.tree
//      .findView(id: .structural(index: 0))? // TestView
//      .findView(id: .structural(index: 0))? // Counter
//      .findView(id: .structural(index: 0))? // VStack
//      .findView(id: .structural(index: 0))? // TupleView
//      .findView(id: .structural(index: 0)) // Text
//    XCTAssertEqual(
//      text?.element?.description,
//      "<TokamakCore.Text content=\"1\" modifiers=\"[]\"></TokamakCore.Text>"
//    )
//    increment?.action()
//    XCTAssertEqual(
//      text?.element?.description,
//      "<TokamakCore.Text content=\"2\" modifiers=\"[]\"></TokamakCore.Text>"
//    )
//    decrement?.action()
//    XCTAssertEqual(
//      text?.element?.description,
//      "<TokamakCore.Text content=\"1\" modifiers=\"[]\"></TokamakCore.Text>"
//    )
  }
}
