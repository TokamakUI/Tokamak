// Copyright 2020-2021 Tokamak contributors
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
//  Created by Carson Katri on 9/23/21.
//

import Foundation
import JavaScriptKit
import TokamakCore

private enum ImageCache {
  private static var values = [String: JSObject]()

  static subscript(_ path: String) -> JSObject? {
    get { values[path] }
    set { values[path] = newValue }
  }
}

extension _Canvas {
  func resolveImage(
    _ image: Image,
    _ environment: EnvironmentValues
  ) -> GraphicsContext.ResolvedImage {
    // FIXME: We don't have a way of calculating the size, since we need to wait for the image
    // to load.
    ._resolved(_ImageProxy(image).provider.resolve(in: environment), size: .zero, baseline: 0)
  }

  func drawImage(
    _ image: GraphicsContext.ResolvedImage,
    at positioning: GraphicsContext._Storage._Operation._ResolvedPositioning,
    with fillStyle: FillStyle?,
    in canvasContext: JSObject
  ) {
    switch image._resolved.storage {
    case let .named(name, bundle):
      let src = bundle?.path(forResource: name, ofType: nil) ?? name

      func draw(_ img: JSObject) {
        // Draw the image on the canvas.
        switch positioning {
        case let .in(rect):
          _ = canvasContext.drawImage!(
            img,
            Double(rect.origin.x), Double(rect.origin.y),
            Double(rect.size.width), Double(rect.size.height)
          )
        case let .at(point, anchor):
          _ = canvasContext.drawImage!(
            img,
            Double(point.x - (anchor.x * CGFloat(img.naturalWidth.number!))),
            Double(point.y - (anchor.y * CGFloat(img.naturalHeight.number!)))
          )
        }
      }

      if let cached = ImageCache[src] {
        draw(cached)
      } else {
        // Create an Image and draw it after it loads.
        let img = JSObject.global.Image.function!.new()

        img.onload = .object(JSOneshotClosure { _ in
          draw(img)
          return .undefined
        })

        img.src = .string(src)

        ImageCache[src] = img
      }
    case let .resizable(nested, _, _):
      // Defer to nested.
      drawImage(
        ._resolved(
          .init(storage: nested, label: nil),
          size: image.size,
          baseline: image.baseline,
          shading: image.shading
        ),
        at: positioning,
        with: fillStyle,
        in: canvasContext
      )
    }
  }
}
