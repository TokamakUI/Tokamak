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
import TokamakStaticHTML

extension _Canvas {
  func resolveSymbol(
    _ symbolID: AnyHashable,
    _ symbol: AnyView,
    _ environment: EnvironmentValues
  ) -> GraphicsContext.ResolvedSymbol {
    let id = "_resolvable_symbol_body_\(UUID().uuidString)"
    let divWrapped = HTML(
      "div",
      ["xmlns": "http://www.w3.org/1999/xhtml", "id": id, "style": "display: inline-block;"]
    ) {
      symbol
        .environmentValues(environment)
    }
    let innerHTML = StaticHTMLRenderer(divWrapped, environment).render()
    // Add the element to the document to read its size.
    let unhostedElement = document.createElement!("div").object!
    unhostedElement.innerHTML = JSValue.string(innerHTML)
    _ = document.body.appendChild(unhostedElement)
    let bounds = document.getElementById!(id).object!.getBoundingClientRect!().object!
    let size = CGSize(width: bounds.width.number!, height: bounds.height.number!)
    // Remove it from the document.
    _ = unhostedElement.parentNode.removeChild(unhostedElement)

    // Render the element with the StaticHTMLRenderer, wrapping it in an SVG tag.
    return ._resolve(
      StaticHTMLRenderer(
        HTML(
          "svg",
          [
            "xmlns": "http://www.w3.org/2000/svg",
            "width": "\(size.width)",
            "height": "\(size.height)",
          ]
        ) {
          HTML("foreignObject", ["width": "100%", "height": "100%"]) {
            divWrapped
          }
        },
        environment
      ).renderRoot(),
      id: symbolID,
      size: size
    )
  }

  func drawSymbol(
    _ symbol: GraphicsContext.ResolvedSymbol,
    at positioning: GraphicsContext._Storage._Operation._ResolvedPositioning,
    in canvasContext: JSObject
  ) {
    func draw(_ img: JSObject) {
      // Draw the SVG on the canvas.
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
          Double(point.x - (anchor.x * symbol.size.width)),
          Double(point.y - (anchor.y * symbol.size.height))
        )
      }
    }

    if let cached = cachedSymbol(id: symbol._id) {
      draw(cached)
    } else {
      // Create an SVG element containing the View's rendered HTML.
      // This was resolved to SVG earlier.
      let img = JSObject.global.Image.function!.new()
      let svgData = JSObject.global.Blob.function!.new(
        [symbol._resolved as? String ?? ""],
        ["type": "image/svg+xml;charset=utf-8"]
      )
      // Create a URL to the SVG data.
      let objectURL = JSObject.global.URL.function!.createObjectURL!(svgData)

      img.onload = .object(JSOneshotClosure { _ in
        draw(img)
        return .undefined
      })

      img.src = objectURL
      cacheSymbol(id: symbol._id, img)
    }
  }
}
