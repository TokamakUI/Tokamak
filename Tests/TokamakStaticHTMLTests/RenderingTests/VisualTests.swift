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
import TokamakCore
import TokamakStaticHTML
import XCTest

final class VisualRenderingTests: XCTestCase {
  func testContentStyles() {
    assertSnapshot(
      matching: HStack {
        Rectangle()
          .frame(width: 50, height: 50)
          .foregroundStyle(HierarchicalShapeStyle.primary)
        Rectangle()
          .frame(width: 50, height: 50)
          .foregroundStyle(HierarchicalShapeStyle.secondary)
        Rectangle()
          .frame(width: 50, height: 50)
          .foregroundStyle(HierarchicalShapeStyle.tertiary)
        Rectangle()
          .frame(width: 50, height: 50)
          .foregroundStyle(HierarchicalShapeStyle.quaternary)
      }
      .foregroundColor(.blue),
      as: .image(size: .init(width: 275, height: 100)),
      timeout: defaultSnapshotTimeout
    )

    assertSnapshot(
      matching: HStack {
        Rectangle()
          .frame(width: 50, height: 50)
          .foregroundStyle(HierarchicalShapeStyle.primary)
        Rectangle()
          .frame(width: 50, height: 50)
          .foregroundStyle(HierarchicalShapeStyle.secondary)
        Rectangle()
          .frame(width: 50, height: 50)
          .foregroundStyle(HierarchicalShapeStyle.tertiary)
        Rectangle()
          .frame(width: 50, height: 50)
          .foregroundStyle(HierarchicalShapeStyle.quaternary)
      }
      .foregroundStyle(Color.red, Color.green, Color.blue),
      as: .image(size: .init(width: 275, height: 100)),
      timeout: defaultSnapshotTimeout
    )
  }

  func testForegroundStyle() {
    assertSnapshot(
      matching: HStack(spacing: 0) {
        Rectangle()
          .frame(width: 50, height: 50)
          .foregroundStyle(Color.red)
        Rectangle()
          .frame(width: 50, height: 50)
          .foregroundStyle(Color.green)
        Rectangle()
          .frame(width: 50, height: 50)
          .foregroundStyle(Color.blue)
      },
      as: .image(size: .init(width: 200, height: 100)),
      timeout: defaultSnapshotTimeout
    )
  }

  func testGradients() {
    let size = CGSize(width: 300, height: 100)
    let gradient = HStack {
      Rectangle()
        .fill(LinearGradient(
          colors: [.red, .orange, .yellow, .green, .blue, .purple],
          startPoint: .bottomLeading,
          endPoint: .topTrailing
        ))
        .frame(width: 80, height: 80)
      Circle()
        .fill(RadialGradient(
          colors: [.red, .orange, .yellow, .green, .blue, .purple],
          center: .center,
          startRadius: 5,
          endRadius: 40
        ))
        .frame(width: 80, height: 80)
      Ellipse()
        .fill(
          AngularGradient(
            colors: [.red, .orange, .yellow, .green, .blue, .purple],
            center: UnitPoint(x: 0.3, y: 0.6),
            startAngle: .degrees(45),
            endAngle: .degrees(120)
          )
        )
        .frame(width: 80, height: 80)
    }

    let matchA = verifySnapshot(
      matching: gradient,
      as: .image(size: size),
      testName: "\(#function)A"
    )
    let matchB = verifySnapshot(
      matching: gradient,
      as: .image(size: size),
      testName: "\(#function)B"
    )

    if matchA == nil { print("\(#function) version A matches") }
    if matchB == nil { print("\(#function) version B matches") }

    XCTAssert(matchA == nil || matchB == nil)
  }

  func testMaterial() {
    assertSnapshot(
      matching: ZStack {
        HStack(spacing: 0) {
          Color.red
          Color.orange
          Color.yellow
          Color.green
          Color.blue
          Color.purple
        }
        VStack(spacing: 0) {
          Color.clear
            .background(Material.ultraThin)
          Color.clear
            .background(Material.ultraThick)
        }
      },
      as: .image(size: .init(width: 100, height: 100)),
      timeout: defaultSnapshotTimeout
    )
  }

  func testOpacity() {
    struct Opacity: View {
      var body: some View {
        ZStack {
          Circle()
            .fill(Color.red)
            .opacity(0.5)
            .frame(width: 25, height: 25)
          Circle()
            .fill(Color.green)
            .opacity(0.5)
            .frame(width: 50, height: 50)
          Circle()
            .fill(Color.blue)
            .opacity(0.5)
            .frame(width: 75, height: 75)
        }
      }
    }

    assertSnapshot(
      matching: Opacity().preferredColorScheme(.light),
      as: .image(size: .init(width: 75, height: 75)),
      timeout: defaultSnapshotTimeout
    )
  }

  func testScaleEffect() {
    assertSnapshot(
      matching: ZStack {
        Circle()
          .fill(Color.red)
          .frame(width: 50, height: 50)
          .scaleEffect(2)
          .opacity(0.5)
        Circle()
          .fill(Color.blue)
          .frame(width: 50, height: 50)
          .opacity(0.5)
      },
      as: .image(size: .init(width: 100, height: 100)),
      timeout: defaultSnapshotTimeout
    )
  }
}

#endif
