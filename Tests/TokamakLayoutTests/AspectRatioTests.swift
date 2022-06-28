// Copyright 2022 Tokamak contributors
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
//  Created by Carson Katri on 6/27/22.
//

#if os(macOS)
import SwiftUI
import TokamakStaticHTML
import XCTest

final class AspectRatioTests: XCTestCase {
  func testAspectRatio() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.Rectangle()
        .fill(Color(white: 0))
        .aspectRatio(1, contentMode: .fit)
        .frame(width: 200, height: 100)
    } to: {
      TokamakStaticHTML.Rectangle()
        .fill(Color(white: 0))
        .aspectRatio(1, contentMode: .fit)
        .frame(width: 200, height: 100)
    }
  }

  func testWideRatio() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.Rectangle()
        .fill(Color(white: 0))
        .aspectRatio(1.5, contentMode: .fit)
        .frame(width: 100, height: 100)
    } to: {
      TokamakStaticHTML.Rectangle()
        .fill(Color(white: 0))
        .aspectRatio(1.5, contentMode: .fit)
        .frame(width: 100, height: 100)
    }
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.Rectangle()
        .fill(Color(white: 0))
        .aspectRatio(1.5, contentMode: .fill)
        .frame(width: 100, height: 100)
    } to: {
      TokamakStaticHTML.Rectangle()
        .fill(Color(white: 0))
        .aspectRatio(1.5, contentMode: .fill)
        .frame(width: 100, height: 100)
    }
  }

  func testTallRatio() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.Rectangle()
        .fill(Color(white: 0))
        .aspectRatio(0.5, contentMode: .fit)
        .frame(width: 100, height: 100)
    } to: {
      TokamakStaticHTML.Rectangle()
        .fill(Color(white: 0))
        .aspectRatio(0.5, contentMode: .fit)
        .frame(width: 100, height: 100)
    }
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.Rectangle()
        .fill(Color(white: 0))
        .aspectRatio(0.5, contentMode: .fill)
        .frame(width: 100, height: 100)
    } to: {
      TokamakStaticHTML.Rectangle()
        .fill(Color(white: 0))
        .aspectRatio(0.5, contentMode: .fill)
        .frame(width: 100, height: 100)
    }
  }
}
#endif
