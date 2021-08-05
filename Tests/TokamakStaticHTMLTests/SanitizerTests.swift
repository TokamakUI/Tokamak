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

@testable import TokamakStaticHTML
import XCTest

final class SanitizerTests: XCTestCase {
  func testCSSString() {
    XCTAssertFalse(Sanitizers.CSS.validate(string: "hello"))
    XCTAssertTrue(Sanitizers.CSS.validate(string: "\"hello\""))
    XCTAssertTrue(Sanitizers.CSS.validate(string: "\'hello\'"))

    XCTAssertEqual(Sanitizers.CSS.sanitize(string: "'hello world'"), "'hello world'")
    XCTAssertEqual(Sanitizers.CSS.sanitize(string: "\"hello world\""), "'hello world'")
    XCTAssertEqual(Sanitizers.CSS.sanitize(string: "hello'''world"), "'helloworld'")
  }

  func testCSSIdentifier() {
    XCTAssertFalse(Sanitizers.CSS.validate(identifier: "\"hey there\""))
    XCTAssertFalse(Sanitizers.CSS.validate(identifier: "1hey-there"))
    XCTAssertTrue(Sanitizers.CSS.validate(identifier: "hey-there"))
    XCTAssertTrue(Sanitizers.CSS.validate(identifier: "-hey-there2"))

    XCTAssertEqual(Sanitizers.CSS.sanitize(identifier: "hello"), "hello")
    XCTAssertEqual(Sanitizers.CSS.sanitize(identifier: "hello-world"), "hello-world")
    XCTAssertEqual(Sanitizers.CSS.sanitize(identifier: "-hello-world_1"), "-hello-world_1")
  }

  func testCSSSanitizer() {
    XCTAssertEqual(Sanitizers.CSS.sanitize("hello world"), "'hello world'")
    XCTAssertEqual(Sanitizers.CSS.sanitize("hello-world"), "hello-world")
  }

  func testHTMLSanitizer() {
    XCTAssertTrue(Sanitizers.HTML.Insecure.validate("<b>\"Hello' & 'World\"</b>"))
    XCTAssertEqual(Sanitizers.HTML.Insecure.sanitize("<b>Hello</b>"), "<b>Hello</b>")
    XCTAssertEqual(Sanitizers.HTML.insecure("\"Hello\" & 'World'"), "\"Hello\" & 'World'")

    XCTAssertFalse(Sanitizers.HTML.Encode.validate("<b>\"Hello' & 'World\"</b>"))
    XCTAssertEqual(Sanitizers.HTML.Encode.sanitize("<b>Hello</b>"), "&lt;b&gt;Hello&lt;/b&gt;")
    XCTAssertEqual(
      Sanitizers.HTML.encode("\"Hello\" & 'World'"),
      "&quot;Hello&quot; &amp; &#x27;World&#x27;"
    )

    XCTAssertFalse(Sanitizers.HTML.Default.validate("<b>\"Hello' & 'World\"</b>"))
    XCTAssertEqual(Sanitizers.HTML.Default.sanitize("<b>Hello</b>"), "&lt;b&gt;Hello&lt;/b&gt;")
    XCTAssertEqual(
      Sanitizers.HTML.Default.sanitize("\"Hello\" & 'World'"),
      "&quot;Hello&quot; &amp; &#x27;World&#x27;"
    )
  }
}
