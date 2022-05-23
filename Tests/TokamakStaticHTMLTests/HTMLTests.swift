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

  func testTitle() {
    let resultingHTML = StaticHTMLRenderer(
      VStack {
        HTMLTitle("Tokamak")
        Text("Hello, world!")
      }
    ).render(shouldSortAttributes: true)

    assert(resultingHTML.contains("<title>Tokamak</title>"))
    assertSnapshot(matching: resultingHTML, as: .html)
  }

  func testDoubleTitle() {
    let resultingHTML = StaticHTMLRenderer(
      VStack {
        HTMLTitle("Tokamak 1")
        Text("Hello, world!")
        VStack {
          HTMLTitle("Tokamak 2")
        }
      }
    ).render(shouldSortAttributes: true)

    assert(resultingHTML.contains("<title>Tokamak 2</title>") == true)
    assert(resultingHTML.contains("<title>Tokamak 1</title>") == false)
    assertSnapshot(matching: resultingHTML, as: .html)
  }

  func testTitleModifier() {
    let resultingHTML = StaticHTMLRenderer(
      Text("Hello, world!")
        .htmlTitle("Tokamak")
    ).render(shouldSortAttributes: true)

    assert(resultingHTML.contains("<title>Tokamak</title>"))
    assertSnapshot(matching: resultingHTML, as: .html)
  }

  func testDoubleTitleModifier() {
    let resultingHTML = StaticHTMLRenderer(
      Text("Hello, world!")
        .htmlTitle("Tokamak 1")
        .htmlTitle("Tokamak 2")
    ).render(shouldSortAttributes: true)

    assert(resultingHTML.contains("<title>Tokamak 2</title>") == true)
    assert(resultingHTML.contains("<title>Tokamak 1</title>") == false)
    assertSnapshot(matching: resultingHTML, as: .html)
  }

  func testMetaCharset() {
    let resultingHTML = StaticHTMLRenderer(
      VStack {
        HTMLMeta(charset: "utf-8")
        Text("Hello, world!")
      }
    ).render(shouldSortAttributes: true)

    assertSnapshot(matching: resultingHTML, as: .html)
  }

  func testMetaCharsetModifier() {
    let resultingHTML = StaticHTMLRenderer(
      Text("Hello, world!")
        .htmlMeta(charset: "utf-8")
    ).render(shouldSortAttributes: true)

    assertSnapshot(matching: resultingHTML, as: .html)
  }

  func testMetaAll() {
    let resultingHTML = StaticHTMLRenderer(
      VStack {
        HTMLMeta(charset: "utf-8")
        HTMLMeta(name: "description", content: "SwiftUI on the web")
        HTMLMeta(property: "og:image", content: "https://image.png")
        HTMLMeta(httpEquiv: "refresh", content: "60")
        Text("Hello, world!")
      }
    ).render(shouldSortAttributes: true)

    assert(resultingHTML.components(separatedBy: "<meta ").count == 5)
    assertSnapshot(matching: resultingHTML, as: .html)
  }

  func testPreferencePropagation() {
    var title0 = ""
    var title1 = ""
    var title2 = ""
    var title3 = ""

    let resultingHTML = StaticHTMLRenderer(
      VStack {
        HTMLTitle("Tokamak 1")
          .onPreferenceChange(HTMLTitlePreferenceKey.self) { title1 = $0 }
        VStack {
          HTMLTitle("Tokamak 2")
        }
        .onPreferenceChange(HTMLTitlePreferenceKey.self) { title2 = $0 }
        VStack {
          HTMLTitle("Tokamak 3")
        }
        .onPreferenceChange(HTMLTitlePreferenceKey.self) { title3 = $0 }
      }
      .onPreferenceChange(HTMLTitlePreferenceKey.self) { title0 = $0 }
    ).render(shouldSortAttributes: true)

    assert(title0 == "Tokamak 3")
    assert(title1 == "Tokamak 1")
    assert(title2 == "Tokamak 2")
    assert(title3 == "Tokamak 3")
    assertSnapshot(matching: resultingHTML, as: .html)
  }
}

#endif
