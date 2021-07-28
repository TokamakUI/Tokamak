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

// SnapshotTesting with image snapshots are only supported on macOS.
#if os(macOS)
import SnapshotTesting
import TokamakStaticHTML
import XCTest

// Needed for `NSImage`, but would be great to make this truly cross-platform.
import class AppKit.NSImage

public extension Snapshotting where Value: View, Format == NSImage {
  static var image: Snapshotting { .image() }

  /// A snapshot strategy for comparing Tokamak Views based on pixel equality.
  static func image(precision: Float = 1, size: CGSize? = nil) -> Snapshotting {
    SimplySnapshotting.image(precision: precision).asyncPullback { view in
      Async { callback in
        let html = Data(StaticHTMLRenderer(view).render().utf8)
        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let renderedPath = cwd.appendingPathComponent("rendered.html")

        // swiftlint:disable:next force_try
        try! html.write(to: renderedPath)
        let browser = Process()
        browser
          .launchPath = "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"

        var arguments = [
          "--headless",
          "--disable-gpu",
          "--force-device-scale-factor=1.0",
          "--force-color-profile=srgb",
          "--screenshot",
          renderedPath.path,
        ]
        if let size = size {
          arguments.append("--window-size=\(Int(size.width)),\(Int(size.height))")
        }

        browser.arguments = arguments
        browser.terminationHandler = { _ in
          callback(NSImage(
            contentsOfFile: cwd.appendingPathComponent("screenshot.png")
              .path
          )!)
        }
        browser.launch()
      }
    }
  }
}

private let defaultSnapshotTimeout: TimeInterval = 10

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

final class RenderingTests: XCTestCase {
  func testPath() {
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

  func testStacks() {
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

  func testOpacity() {
    assertSnapshot(
      matching: Opacity().preferredColorScheme(.light),
      as: .image(size: .init(width: 75, height: 75)),
      timeout: defaultSnapshotTimeout
    )
  }

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

  func testFrames() {
    assertSnapshot(
      matching: Color.red
        .frame(width: 20, height: 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing),
      as: .image(size: .init(width: 50, height: 50)),
      timeout: defaultSnapshotTimeout
    )
  }

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

  func testGradients() {
    assertSnapshot(
      matching: HStack {
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
      },
      as: .image(size: .init(width: 200, height: 100))
    )
  }
}

#endif
