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
import TokamakTestRenderer

private struct TestView: View {
  struct Counter: View {
    @State
    private var count = 0

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

final class VisitorTests: XCTestCase {
  func testRenderer() {
    let reconciler = TestFiberRenderer(.root, size: .init(width: 500, height: 500))
      .render(TestView())
    func decrement() {
      (
        reconciler.current // RootView
          .child? // ModifiedContent
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
        reconciler.current // RootView
          .child? // ModifiedContent
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
    for _ in 0..<5 {
      increment()
    }
    decrement()
  }
}
