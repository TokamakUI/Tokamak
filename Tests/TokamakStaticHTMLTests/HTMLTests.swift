// Copyright 2020 Tokamak contributors
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
//  Created by Max Desiatov on 07/12/2018.
//

#if canImport(SnapshotTesting)

import SnapshotTesting
import TokamakStaticHTML
import XCTest

final class HTMLTests: XCTestCase {
  struct Model {
    let color: Color
  }

  private struct OptionalBody: View {
    var model: Model?

    var body: some View {
      if let color = model?.color {
        VStack {
          color

          Spacer()
        }
      }
    }
  }

  func testOptional() {
    let resultingHTML = StaticHTMLRenderer(OptionalBody(model: Model(color: Color.red)))
      .render(shouldSortAttributes: true)

    assertSnapshot(matching: resultingHTML, as: .html)
  }

  func testPaddingFusion() {
    let nestedTwice = StaticHTMLRenderer(
      Color.red.padding(10).padding(20)
    ).render(shouldSortAttributes: true)

    assertSnapshot(matching: nestedTwice, as: .html)

    let nestedThrice = StaticHTMLRenderer(
      Color.red.padding(20).padding(20).padding(20)
    ).render(shouldSortAttributes: true)

    assertSnapshot(matching: nestedThrice, as: .html)
  }

  func testFontStacks() {
    let customFont = StaticHTMLRenderer(
      Text("Hello, world!")
        .font(.custom("Marker Felt", size: 17))
    ).render(shouldSortAttributes: true)

    assertSnapshot(matching: customFont, as: .html)

    let fallbackFont = StaticHTMLRenderer(
      VStack {
        Text("Hello, world!")
          .font(.custom("Marker Felt", size: 17))
      }
      .font(.system(.body, design: .serif))
    ).render(shouldSortAttributes: true)

    assertSnapshot(matching: fallbackFont, as: .html)
  }

  func testHTMLSanitizer() {
    let text = "<b>\"Hello\" & 'World'</b> "

    let sanitizedHTML = StaticHTMLRenderer(Text(text))
      .render(shouldSortAttributes: true)
    assertSnapshot(matching: sanitizedHTML, as: .html)

    let insecureHTML =
      StaticHTMLRenderer(Text(text)._domTextSanitizer(Sanitizers.HTML.insecure))
        .render(shouldSortAttributes: true)
    assertSnapshot(matching: insecureHTML, as: .html)
  }
}

#endif
