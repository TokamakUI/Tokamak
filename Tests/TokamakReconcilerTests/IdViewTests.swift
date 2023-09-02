// Copyright 2023 Tokamak contributors
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
//  Created by Lukas Stabe on 09/02/23.
//

import XCTest

@_spi(TokamakCore) @testable import TokamakCore
import TokamakTestRenderer

final class IdViewTests: XCTestCase {
  func testResettingStateViaId() {
    struct Nested: View {
      @State var count = 0
      var body: some View {
        Text("count \(count)")
        Button("inc") { count += 1 }.identified(by: "inc")
      }
    }

    struct Main: View {
      @State var id = 0

      var body: some View {
        Nested().id(id)
        Button("reset") { id += 1 }.identified(by: "reset")
      }
    }

    let reconciler = TestFiberRenderer(.root, size: .zero).render(Main())
    let root = reconciler.renderer.rootElement

    XCTAssert(root.children.count == 3)
    XCTAssert(root.children[0].description.contains(#""count 0""#))

    reconciler.findView(id: "inc").tap()
    XCTAssert(root.children[0].description.contains(#""count 1""#))

    reconciler.findView(id: "reset").tap()

    XCTAssert(root.children[0].description.contains(#""count 0""#))
  }
}
