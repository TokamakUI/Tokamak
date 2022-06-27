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
@_spi(TokamakStaticHTML) import TokamakStaticHTML
import XCTest

func compare<A: SwiftUI.View, B: TokamakStaticHTML.View>(
  size: CGSize,
  @SwiftUI.ViewBuilder _ native: () -> A,
  @TokamakStaticHTML.ViewBuilder to tokamak: () -> B
) async {
  let nativePNG = await render(size: size) {
    native()
  }
  let tokamakPNG = await render(size: size) {
    tokamak()
  }

  let match = nativePNG == tokamakPNG
  XCTAssert(match)

  if !match {
    let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    // swiftlint:disable:next force_try
    try! nativePNG.write(to: cwd.appendingPathComponent("_layouttests_native.png"))
    // swiftlint:disable:next force_try
    try! tokamakPNG.write(to: cwd.appendingPathComponent("_layouttests_tokamak.png"))
    print("You can view the diffs at \(cwd.absoluteString)")
  }
}

@MainActor
private func render<V: SwiftUI.View>(
  size: CGSize,
  @SwiftUI.ViewBuilder _ view: () -> V
) -> Data {
  let bounds = CGRect(origin: .zero, size: .init(width: size.width, height: size.height))

  let view = NSHostingView(rootView: view().preferredColorScheme(.light))
  view.setFrameSize(bounds.size)
  view.layer?.backgroundColor = .white

  let bitmap = view.bitmapImageRepForCachingDisplay(in: bounds)!
  view.cacheDisplay(in: bounds, to: bitmap)

  let scale = 1 / (NSScreen.main?.backingScaleFactor ?? 1)
  return CIContext().pngRepresentation(
    of: CIImage(bitmapImageRep: bitmap)!
      .transformed(by: .init(scaleX: scale, y: scale)),
    format: .RGBA8,
    colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
  )!
}

private func render<V: TokamakStaticHTML.View>(
  size: CGSize,
  @TokamakStaticHTML.ViewBuilder _ view: () -> V
) async -> Data {
  await withCheckedContinuation { (continuation: CheckedContinuation<Data, Never>) in
    let renderer = StaticHTMLFiberRenderer(useDynamicLayout: true, sceneSize: size)
    let html = Data(renderer.render(view()).utf8)
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
      "--hide-scrollbars",
      "--screenshot",
      renderedPath.path,
    ]

    arguments.append("--window-size=\(Int(size.width)),\(Int(size.height))")

    browser.arguments = arguments
    browser.terminationHandler = { _ in
      let cgImage = NSImage(
        contentsOf: cwd.appendingPathComponent("screenshot.png")
      )!
        .cgImage(forProposedRect: nil, context: nil, hints: nil)!
      let png = CIContext().pngRepresentation(
        of: CIImage(cgImage: cgImage),
        format: .RGBA8,
        colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
      )!
      continuation.resume(returning: png)
    }
    browser.launch()
  }
}
#endif
