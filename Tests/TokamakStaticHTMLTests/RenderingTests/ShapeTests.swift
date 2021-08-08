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

final class ShapeRenderingTests: XCTestCase {
  func testContainerRelativeShape() {
    assertSnapshot(
      matching: ZStack {
        ContainerRelativeShape()
          .fill(Color.blue)
          .frame(width: 100, height: 100, alignment: .center)
        ContainerRelativeShape()
          .fill(Color.green)
          .frame(width: 50, height: 50)
      }.containerShape(Circle()),
      as: .image(size: .init(width: 150, height: 150)),
      timeout: defaultSnapshotTimeout
    )
  }

  func testPath() {
    struct Star: Shape {
      func path(in rect: CGRect) -> Path {
        Path { path in
          path.move(to: .init(x: 40, y: 0))
          path.addLine(to: .init(x: 20, y: 76))
          path.addLine(to: .init(x: 80, y: 30.4))
          path.addLine(to: .init(x: 0, y: 30.4))
          path.addLine(to: .init(x: 64, y: 76))
          path.addLine(to: .init(x: 40, y: 0))
        }
      }
    }

    assertSnapshot(
      matching: Star().fill(Color(red: 1, green: 0.75, blue: 0.1, opacity: 1)),
      as: .image(size: .init(width: 100, height: 100)),
      timeout: defaultSnapshotTimeout
    )
  }

  func testStrokedCircle() {
    assertSnapshot(
      matching: Circle().stroke(Color.green).frame(width: 100, height: 100, alignment: .center),
      as: .image(size: .init(width: 150, height: 150)),
      timeout: defaultSnapshotTimeout
    )
  }
}

#endif
