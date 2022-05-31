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
import XCTest

@testable import TokamakCore

private struct TestView: View {
  @Environment(\.colorScheme)
  var colorScheme

  public var body: some View {
    EmptyView()
  }
}

final class EnvironmentTests: XCTestCase {
  func testInjection() {
    var test: Any = TestView()
    var values = EnvironmentValues()
    values.colorScheme = .light
    values.inject(into: &test, TestView.self)
    // swiftlint:disable:next force_cast
    XCTAssertEqual((test as! TestView).colorScheme, .light)

    values.colorScheme = .dark
    values.inject(into: &test, TestView.self)
    // swiftlint:disable:next force_cast
    XCTAssertEqual((test as! TestView).colorScheme, .dark)

    let modifier = TestView().colorScheme(.light)
    var anyModifier: Any = modifier

    values.inject(into: &anyModifier, type(of: modifier))
    XCTAssertEqual(values.colorScheme, .light)
  }
}
