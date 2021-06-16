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
//
//  Created by Max Desiatov on 13/06/2021.
//

// SnapshotTesting with image snapshots are only supported on iOS.
#if !os(WASI)
import SnapshotTesting

#if TOKAMAK_CONTROL_SNAPSHOTS
import SwiftUI
#else
import TokamakStaticHTML
#endif

import XCTest

struct HStackTest: View {
  let spacing: CGFloat
  var body: some View {
    HStack(spacing: spacing) {
      Rectangle()
        .background(Color.red)

      Rectangle()
        .background(Color.green)

      Rectangle()
        .background(Color.blue)
    }.frame(width: 300, height: 100)
  }
}

final class SnapshotTests: XCTestCase {
  func testHStack() {
    assertSnapshot(matching: HStackTest(spacing: 0), as: .image())
    assertSnapshot(matching: HStackTest(spacing: 10), as: .image())
    assertSnapshot(matching: HStackTest(spacing: 100), as: .image())
  }
}

#endif
