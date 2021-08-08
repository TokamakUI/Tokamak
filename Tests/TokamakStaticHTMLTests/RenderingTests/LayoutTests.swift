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

final class LayoutRenderingTests: XCTestCase {
  func testAnchoredModifiers() {
    assertSnapshot(
      matching: ZStack {
        Circle()
          .fill(Color.red)
          .frame(width: 50, height: 50)
          .scaleEffect(2, anchor: .topLeading)
          .opacity(0.5)
        Circle()
          .fill(Color.blue)
          .frame(width: 50, height: 50)
          .scaleEffect(2, anchor: .center)
          .opacity(0.5)

        Rectangle()
          .fill(Color.red)
          .frame(width: 50, height: 50)
          .rotationEffect(.degrees(45), anchor: .topLeading)
          .opacity(0.5)
        Rectangle()
          .fill(Color.blue)
          .frame(width: 50, height: 50)
          .rotationEffect(.degrees(45), anchor: .center)
          .opacity(0.5)
      },
      as: .image(size: .init(width: 200, height: 200)),
      timeout: defaultSnapshotTimeout
    )
  }

  func testAspectRatio() {
    assertSnapshot(
      matching: Ellipse()
        .fill(Color.purple)
        .aspectRatio(0.75, contentMode: .fit)
        .frame(width: 100, height: 100)
        .border(Color(white: 0.75)),
      as: .image(size: .init(width: 125, height: 125)),
      timeout: defaultSnapshotTimeout
    )

    assertSnapshot(
      matching: Ellipse()
        .fill(Color.purple)
        .aspectRatio(0.75, contentMode: .fill)
        .frame(width: 100, height: 100)
        .border(Color(white: 0.75)),
      as: .image(size: .init(width: 125, height: 125)),
      timeout: defaultSnapshotTimeout
    )
  }

  func testBackground() {
    assertSnapshot(
      matching: Rectangle()
        .fill(Color.blue)
        .opacity(0.5)
        .frame(width: 80, height: 80)
        .background(
          RoundedRectangle(cornerRadius: 10).fill(Color.red)
        ),
      as: .image(size: .init(width: 100, height: 100))
    )

    assertSnapshot(
      matching: Rectangle()
        .fill(Color.blue)
        .opacity(0.5)
        .frame(width: 80, height: 80)
        .background(
          RoundedRectangle(cornerRadius: 10)
            .fill(Color.red)
            .frame(width: 40, height: 40),
          alignment: .bottomTrailing
        ),
      as: .image(size: .init(width: 100, height: 100))
    )
  }

  func testFrames() {
    assertSnapshot(
      matching: Color.red
        .frame(width: 20, height: 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing),
      as: .image(size: .init(width: 50, height: 50)),
      timeout: defaultSnapshotTimeout
    )
  }

  func testOverlay() {
    assertSnapshot(
      matching: Rectangle()
        .fill(Color.blue)
        .frame(width: 80, height: 80)
        .overlay(
          RoundedRectangle(cornerRadius: 10)
            .fill(Color.red.opacity(0.5))
        ),
      as: .image(size: .init(width: 100, height: 100))
    )

    assertSnapshot(
      matching: Rectangle()
        .fill(Color.blue)
        .frame(width: 80, height: 80)
        .overlay(
          RoundedRectangle(cornerRadius: 10)
            .fill(Color.red)
            .frame(width: 40, height: 40),
          alignment: .bottomTrailing
        ),
      as: .image(size: .init(width: 100, height: 100))
    )
  }

  func testStacks() {
    struct Stacks: View {
      let spacing: CGFloat

      var body: some View {
        VStack(spacing: spacing) {
          HStack(spacing: spacing) {
            Rectangle()
              .fill(Color.red)
              .frame(width: 100, height: 100)

            Rectangle()
              .fill(Color.green)
              .frame(width: 100, height: 100)
          }

          HStack(spacing: spacing) {
            Rectangle()
              .fill(Color.blue)
              .frame(width: 100, height: 100)

            Rectangle()
              .fill(Color.black)
              .frame(width: 100, height: 100)
          }
        }
      }
    }

    assertSnapshot(
      matching: Stacks(spacing: 10),
      as: .image(size: .init(width: 210, height: 210)),
      timeout: defaultSnapshotTimeout
    )

    assertSnapshot(
      matching: Stacks(spacing: 20),
      as: .image(size: .init(width: 220, height: 220)),
      timeout: defaultSnapshotTimeout
    )
  }
}

#endif
