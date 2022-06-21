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

@available(macOS 12.0, *)
final class ContainedZLayoutTests: XCTestCase {
  func testBackground() async {
    for (nativeHorizontal, tokamakHorizontal) in SwiftUI.HorizontalAlignment.allCases {
      for (nativeVertical, tokamakVertical) in SwiftUI.VerticalAlignment.allCases {
        await compare(size: .init(width: 500, height: 500)) {
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 127 / 255))
            .frame(width: 100, height: 100)
            .background(alignment: .init(
              horizontal: nativeHorizontal,
              vertical: nativeVertical
            )) {
              SwiftUI.Rectangle()
                .fill(SwiftUI.Color(white: 0))
                .frame(width: 50, height: 50)
            }
        } to: {
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 127 / 255))
            .frame(width: 100, height: 100)
            .background(alignment: .init(
              horizontal: tokamakHorizontal,
              vertical: tokamakVertical
            )) {
              TokamakStaticHTML.Rectangle()
                .fill(TokamakStaticHTML.Color(white: 0))
                .frame(width: 50, height: 50)
            }
        }
      }
    }
  }

  func testOverlay() async {
    for (nativeHorizontal, tokamakHorizontal) in SwiftUI.HorizontalAlignment.allCases {
      for (nativeVertical, tokamakVertical) in SwiftUI.VerticalAlignment.allCases {
        await compare(size: .init(width: 500, height: 500)) {
          SwiftUI.Rectangle()
            .fill(SwiftUI.Color(white: 127 / 255))
            .frame(width: 100, height: 100)
            .overlay(alignment: .init(
              horizontal: nativeHorizontal,
              vertical: nativeVertical
            )) {
              SwiftUI.Rectangle()
                .fill(SwiftUI.Color(white: 0))
                .frame(width: 50, height: 50)
            }
        } to: {
          TokamakStaticHTML.Rectangle()
            .fill(TokamakStaticHTML.Color(white: 127 / 255))
            .frame(width: 100, height: 100)
            .overlay(alignment: .init(
              horizontal: tokamakHorizontal,
              vertical: tokamakVertical
            )) {
              TokamakStaticHTML.Rectangle()
                .fill(TokamakStaticHTML.Color(white: 0))
                .frame(width: 50, height: 50)
            }
        }
      }
    }
  }
}
#endif
