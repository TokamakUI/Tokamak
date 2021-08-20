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
//  Created by Carson Katri on 8/7/21.
//

// SnapshotTesting with image snapshots are only supported on macOS.
#if os(macOS)
import SnapshotTesting
import TokamakStaticHTML
import XCTest

final class ViewRenderingTests: XCTestCase {
  func testProgressView() {
    assertSnapshot(
      matching: VStack(spacing: 0) {
        ProgressView(value: 0.5) {
          Text("Loading")
        } currentValueLabel: {
          Text("0.5")
        }
        ProgressView(Progress(totalUnitCount: 3))
      },
      as: .image(size: .init(width: 200, height: 200)),
      timeout: defaultSnapshotTimeout
    )
  }
}

#endif
