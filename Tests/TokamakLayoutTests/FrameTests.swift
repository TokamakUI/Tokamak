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
//  Created by Carson Katri on 6/20/22.
//

#if os(macOS)
import SwiftUI
import TokamakStaticHTML
import XCTest

final class FrameTests: XCTestCase {
  func testFixedFrame() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.Rectangle()
        .fill(SwiftUI.Color(white: 0))
        .frame(width: 200, height: 100)
    } to: {
      TokamakStaticHTML.Rectangle()
        .fill(TokamakStaticHTML.Color(white: 0))
        .frame(width: 200, height: 100)
    }
  }

  func testFixedWidth() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.Rectangle()
        .fill(SwiftUI.Color(white: 0))
        .frame(width: 200)
    } to: {
      TokamakStaticHTML.Rectangle()
        .fill(TokamakStaticHTML.Color(white: 0))
        .frame(width: 200)
    }
  }

  func testFixedHeight() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.Rectangle()
        .fill(SwiftUI.Color(white: 0))
        .frame(height: 200)
    } to: {
      TokamakStaticHTML.Rectangle()
        .fill(TokamakStaticHTML.Color(white: 0))
        .frame(height: 200)
    }
  }

  func testFlexibleFrame() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.Rectangle()
        .fill(SwiftUI.Color(white: 0))
        .frame(minWidth: 0, maxWidth: 200, minHeight: 0, maxHeight: 100)
    } to: {
      TokamakStaticHTML.Rectangle()
        .fill(TokamakStaticHTML.Color(white: 0))
        .frame(minWidth: 0, maxWidth: 200, minHeight: 0, maxHeight: 100)
    }
  }

  func testFlexibleWidth() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.Rectangle()
        .fill(SwiftUI.Color(white: 0))
        .frame(minWidth: 0, maxWidth: 200)
    } to: {
      TokamakStaticHTML.Rectangle()
        .fill(TokamakStaticHTML.Color(white: 0))
        .frame(minWidth: 0, maxWidth: 200)
    }
  }

  func testFlexibleHeight() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.Rectangle()
        .fill(SwiftUI.Color(white: 0))
        .frame(minHeight: 0, maxHeight: 200)
    } to: {
      TokamakStaticHTML.Rectangle()
        .fill(TokamakStaticHTML.Color(white: 0))
        .frame(minHeight: 0, maxHeight: 200)
    }
  }

  func testAlignment() async {
    for (nativeHorizontal, tokamakHorizontal) in SwiftUI.HorizontalAlignment.allCases {
      for (nativeVertical, tokamakVertical) in SwiftUI.VerticalAlignment.allCases {
        await compare(size: .init(width: 500, height: 500)) {
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 0))
            .frame(width: 100, height: 100)
            .frame(
              maxWidth: .infinity,
              maxHeight: .infinity,
              alignment: .init(horizontal: nativeHorizontal, vertical: nativeVertical)
            )
            .background(Color(white: 127 / 255))
        } to: {
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 0))
            .frame(width: 100, height: 100)
            .frame(
              maxWidth: .infinity,
              maxHeight: .infinity,
              alignment: .init(
                horizontal: tokamakHorizontal,
                vertical: tokamakVertical
              )
            )
            .background(Color(white: 127 / 255))
        }
      }
    }
  }
}
#endif
