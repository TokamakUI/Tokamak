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

final class StackTests: XCTestCase {
  func testVStack() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.VStack {
        SwiftUI.Rectangle().fill(SwiftUI.Color(white: 0))
        SwiftUI.Rectangle().fill(SwiftUI.Color(white: 127 / 255))
      }
    } to: {
      TokamakStaticHTML.VStack {
        TokamakStaticHTML.Rectangle().fill(TokamakStaticHTML.Color(white: 0))
        TokamakStaticHTML.Rectangle().fill(TokamakStaticHTML.Color(white: 127 / 255))
      }
    }
  }

  func testHStack() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.HStack {
        SwiftUI.Rectangle().fill(SwiftUI.Color(white: 0))
        SwiftUI.Rectangle().fill(SwiftUI.Color(white: 127 / 255))
      }
    } to: {
      TokamakStaticHTML.HStack {
        TokamakStaticHTML.Rectangle().fill(TokamakStaticHTML.Color(white: 0))
        TokamakStaticHTML.Rectangle().fill(TokamakStaticHTML.Color(white: 127 / 255))
      }
    }
  }

  func testVStackSpacing() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.VStack(spacing: 0) {
        SwiftUI.Rectangle().fill(SwiftUI.Color(white: 0))
        SwiftUI.Rectangle().fill(SwiftUI.Color(white: 127 / 255))
      }
    } to: {
      TokamakStaticHTML.VStack(spacing: 0) {
        TokamakStaticHTML.Rectangle().fill(TokamakStaticHTML.Color(white: 0))
        TokamakStaticHTML.Rectangle().fill(TokamakStaticHTML.Color(white: 127 / 255))
      }
    }
  }

  func testHStackSpacing() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.HStack(spacing: 0) {
        SwiftUI.Rectangle().fill(SwiftUI.Color(white: 0))
        SwiftUI.Rectangle().fill(SwiftUI.Color(white: 127 / 255))
      }
    } to: {
      TokamakStaticHTML.HStack(spacing: 0) {
        TokamakStaticHTML.Rectangle().fill(TokamakStaticHTML.Color(white: 0))
        TokamakStaticHTML.Rectangle().fill(TokamakStaticHTML.Color(white: 127 / 255))
      }
    }
  }

  func testVStackAlignment() async {
    for (nativeAlignment, tokamakAlignment) in SwiftUI.HorizontalAlignment.allCases {
      await compare(size: .init(width: 500, height: 500)) {
        SwiftUI.VStack(alignment: nativeAlignment) {
          SwiftUI.Rectangle().fill(SwiftUI.Color(white: 0))
          SwiftUI.Rectangle().fill(SwiftUI.Color(white: 127 / 255))
            .frame(width: 50)
        }
      } to: {
        TokamakStaticHTML.VStack(alignment: tokamakAlignment) {
          TokamakStaticHTML.Rectangle().fill(TokamakStaticHTML.Color(white: 0))
          TokamakStaticHTML.Rectangle().fill(TokamakStaticHTML.Color(white: 127 / 255))
            .frame(width: 50)
        }
      }
    }
  }

  func testHStackAlignment() async {
    for (nativeAlignment, tokamakAlignment) in SwiftUI.VerticalAlignment.allCases {
      await compare(size: .init(width: 500, height: 500)) {
        SwiftUI.HStack(alignment: nativeAlignment) {
          SwiftUI.Rectangle().fill(SwiftUI.Color(white: 0))
          SwiftUI.Rectangle().fill(SwiftUI.Color(white: 127 / 255))
            .frame(height: 50)
        }
      } to: {
        TokamakStaticHTML.HStack(alignment: tokamakAlignment) {
          TokamakStaticHTML.Rectangle().fill(TokamakStaticHTML.Color(white: 0))
          TokamakStaticHTML.Rectangle().fill(TokamakStaticHTML.Color(white: 127 / 255))
            .frame(height: 50)
        }
      }
    }
  }

  func testVStackPriority() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.VStack {
        SwiftUI.Rectangle().fill(SwiftUI.Color(white: 0))
          .frame(minHeight: 50)
        SwiftUI.Rectangle().fill(SwiftUI.Color(white: 127 / 255))
          .layoutPriority(1)
      }
    } to: {
      TokamakStaticHTML.VStack {
        TokamakStaticHTML.Rectangle().fill(TokamakStaticHTML.Color(white: 0))
          .frame(minHeight: 50)
        TokamakStaticHTML.Rectangle().fill(TokamakStaticHTML.Color(white: 127 / 255))
          .layoutPriority(1)
      }
    }
  }

  func testHStackPriority() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.HStack {
        SwiftUI.Rectangle().fill(SwiftUI.Color(white: 0))
          .frame(minHeight: 50)
        SwiftUI.Rectangle().fill(SwiftUI.Color(white: 127 / 255))
          .layoutPriority(1)
      }
    } to: {
      TokamakStaticHTML.HStack {
        TokamakStaticHTML.Rectangle().fill(TokamakStaticHTML.Color(white: 0))
          .frame(minHeight: 50)
        TokamakStaticHTML.Rectangle().fill(TokamakStaticHTML.Color(white: 127 / 255))
          .layoutPriority(1)
      }
    }
  }
}
#endif
