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

extension _Canvas {
  func resolveText(in canvasContext: JSObject)
    -> (Text, EnvironmentValues) -> GraphicsContext.ResolvedText
  {
    { text, environment in
      ._resolved(
        text,
        shading: .foreground,
        lazyLayoutComputer: { _ in
          _ = canvasContext.save!()
          applyModifiers(
            _TextProxy(text).modifiers,
            to: canvasContext,
            in: environment
          )
          let metrics = canvasContext.measureText!(_TextProxy(text).rawText)
          _ = canvasContext.restore!()
          let baselineToTop = metrics.actualBoundingBoxAscent.number ?? 0
          let baselineToBottom = metrics.actualBoundingBoxDescent.number ?? 0
          return .init(
            size: .init(
              width: CGFloat(metrics.width.number ?? 0),
              height: CGFloat(baselineToTop + baselineToBottom)
            ),
            firstBaseline: CGFloat(baselineToTop),
            lastBaseline: CGFloat(baselineToBottom)
          )
        }
      )
    }
  }

  func drawText(
    _ text: GraphicsContext.ResolvedText,
    at positioning: GraphicsContext._Storage._Operation._ResolvedPositioning,
    in canvasContext: JSObject
  ) {
    let proxy = _TextProxy(text._text)

    _ = canvasContext.save!()
    canvasContext.fillStyle = text.shading.cssValue(
      in: parent._environment,
      with: canvasContext,
      bounds: .zero
    )
    switch positioning {
    case let .in(rect):
      _ = canvasContext.fillText!(
        _TextProxy(text._text).rawText,
        Double(rect.origin.x),
        Double(rect.origin.y),
        Double(rect.size.width)
      )
    case let .at(point, anchor):
      // Horizontal alignment
      canvasContext.textAlign = .string(
        anchor.x == 0 ? "start" : (anchor.x == 0.5 ? "center" : "end")
      )
      // Vertical alignment
      canvasContext.textBaseline = .string(
        anchor
          .y == 0 ? "top" :
          (anchor.y == 0.5 ? "middle" : (anchor.y == 1 ? "bottom" : "alphabetic"))
      )
      applyModifiers(proxy.modifiers, to: canvasContext, in: parent._environment)
      _ = canvasContext.fillText!(proxy.rawText, Double(point.x), Double(point.y))
    }
    _ = canvasContext.restore!()
  }

  private func applyModifiers(
    _ modifiers: [Text._Modifier],
    to canvas: JSObject,
    in environment: EnvironmentValues
  ) {
    var style = ""
    var variant = ""
    var weight = ""
    var size: String?
    var lineHeight = ""
    var family: String?
    for modifier in modifiers {
      switch modifier {
      case let .color(color):
        if let color = color {
          canvas.fillStyle = GraphicsContext.Shading.color(color)
            .cssValue(in: environment, with: canvas, bounds: .zero)
        }
      case let .font(font):
        if let font = font {
          let styles = font.styles(in: environment)
          style += styles["font-style"] ?? ""
          variant += styles["font-variant"] ?? ""
          weight = styles["font-weight"] ?? ""
          size = styles["font-size"] ?? ""
          lineHeight = styles["line-height"] ?? ""
          family = styles["font-family"] ?? ""
        }
      case .italic:
        style += "italic"
      case let .weight(w):
        if let value = w?.value {
          weight = "\(value)"
        }
      case .kerning, .tracking, .rounded, .baseline, .strikethrough,
           .underline: break // Not supported in <canvas>.
      }
    }

    canvas
      .font =
      .string(
        """
        \(style) \(variant) \(weight) \(size ?? "17")pt \(lineHeight) \(
          family ?? Font.Design.default.families.joined(separator: ", ")
        )
        """
      )
  }
}
