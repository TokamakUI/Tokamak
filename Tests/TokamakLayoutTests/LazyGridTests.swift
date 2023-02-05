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
//  Created by Carson Katri on 2/4/23.
//

#if os(macOS)
import SwiftUI
import TokamakStaticHTML
import XCTest

final class LazyGridTests: XCTestCase {
  @available(macOS 13.0, *)
  func testLazyVGrid() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.LazyVGrid(columns: [.init(.adaptive(minimum: 100))], spacing: 10) {
        ForEach(0..<10) { _ in
          Rectangle()
            .fill(Color(white: 0))
            .frame(height: 100)
        }
      }
    } to: {
      TokamakStaticHTML.LazyVGrid(columns: [.init(.adaptive(minimum: 100))], spacing: 10) {
        ForEach(0..<10) { _ in
          Rectangle()
            .fill(Color(white: 0))
            .frame(height: 100)
        }
      }
    }
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.LazyVGrid(
        columns: [.init(.fixed(100)), .init(.fixed(100), spacing: 0), .init(.flexible())],
        spacing: 10
      ) {
        ForEach(0..<10) { _ in
          Rectangle()
            .fill(Color(white: 0))
            .frame(height: 100)
        }
      }
    } to: {
      TokamakStaticHTML.LazyVGrid(
        columns: [.init(.fixed(100)), .init(.fixed(100), spacing: 0), .init(.flexible())],
        spacing: 10
      ) {
        ForEach(0..<10) { _ in
          Rectangle()
            .fill(Color(white: 0))
            .frame(height: 100)
        }
      }
    }
  }

  @available(macOS 13.0, *)
  func testLazyHGrid() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.LazyHGrid(rows: [.init(.adaptive(minimum: 100))], spacing: 10) {
        ForEach(0..<10) { _ in
          Rectangle()
            .fill(Color(white: 0))
            .frame(width: 100)
        }
      }
    } to: {
      TokamakStaticHTML.LazyHGrid(rows: [.init(.adaptive(minimum: 100))], spacing: 10) {
        ForEach(0..<10) { _ in
          Rectangle()
            .fill(Color(white: 0))
            .frame(width: 100)
        }
      }
    }
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.LazyHGrid(
        rows: [.init(.fixed(100)), .init(.fixed(100), spacing: 0), .init(.flexible())],
        spacing: 10
      ) {
        ForEach(0..<10) { _ in
          Rectangle()
            .fill(Color(white: 0))
            .frame(width: 100)
        }
      }
    } to: {
      TokamakStaticHTML.LazyHGrid(
        rows: [.init(.fixed(100)), .init(.fixed(100), spacing: 0), .init(.flexible())],
        spacing: 10
      ) {
        ForEach(0..<10) { _ in
          Rectangle()
            .fill(Color(white: 0))
            .frame(width: 100)
        }
      }
    }
  }
}
#endif
