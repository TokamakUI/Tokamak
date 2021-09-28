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
  func clip(to path: Path, in canvasContext: JSObject) {
    _ = canvasContext.beginPath!()
    pushPath(path, in: canvasContext)
    _ = canvasContext.closePath!()
    _ = canvasContext.clip!()
  }

  func fillPath(
    _ path: Path,
    with shading: GraphicsContext.Shading,
    style fillStyle: FillStyle,
    in canvasContext: JSObject
  ) {
    _ = canvasContext.save!()
    _ = canvasContext.beginPath!()
    pushPath(path, in: canvasContext)
    _ = canvasContext.closePath!()
    canvasContext.fillStyle = shading.cssValue(
      in: parent._environment,
      with: canvasContext,
      bounds: path.boundingRect
    )
    _ = canvasContext.fill!(fillStyle.isEOFilled ? "evenodd" : "nonzero")
    _ = canvasContext.restore!()
  }

  func strokePath(
    _ path: Path,
    with shading: GraphicsContext.Shading,
    style strokeStyle: StrokeStyle,
    in canvasContext: JSObject
  ) {
    _ = canvasContext.save!()
    _ = canvasContext.beginPath!()
    pushPath(path, in: canvasContext)
    _ = canvasContext.closePath!()
    canvasContext.strokeStyle = shading.cssValue(
      in: parent._environment,
      with: canvasContext,
      bounds: path.boundingRect
    )
    canvasContext.lineWidth = .number(Double(strokeStyle.lineWidth))
    _ = canvasContext.stroke!()
    _ = canvasContext.restore!()
  }

  private func pushPath(_ path: Path, in canvasContext: JSObject) {
    switch path.storage {
    case .empty: break
    case let .rect(rect):
      rect.pushRect(to: canvasContext)
    case let .ellipse(rect):
      rect.pushEllipse(to: canvasContext)
    case let .roundedRect(rect):
      rect.push(to: canvasContext)
    case let .path(box):
      for element in box.elements {
        switch element {
        case let .move(point):
          _ = canvasContext.moveTo!(Double(point.x), Double(point.y))
        case let .line(point):
          _ = canvasContext.lineTo!(Double(point.x), Double(point.y))
        case let .quadCurve(endPoint, controlPoint):
          _ = canvasContext.quadraticCurveTo!(
            Double(controlPoint.x),
            Double(controlPoint.y),
            Double(endPoint.x),
            Double(endPoint.y)
          )
        case let .curve(endPoint, control1, control2):
          _ = canvasContext.bezierCurveTo!(
            Double(control1.x),
            Double(control1.y),
            Double(control2.x),
            Double(control2.y),
            Double(endPoint.x),
            Double(endPoint.y)
          )
        case .closeSubpath:
          _ = canvasContext.closePath!() // Close the path.
          _ = canvasContext.beginPath!() // Reopen for the next segments.
        }
      }
    case let .stroked(stroked):
      pushPath(stroked.path, in: canvasContext)
    case let .trimmed(trimmed):
      pushPath(trimmed.path, in: canvasContext) // TODO: Find a way to trim a Path2D
    }
  }
}

private extension CGRect {
  func pushRect(to canvasContext: JSObject) {
    _ = canvasContext.rect!(
      Double(origin.x),
      Double(origin.y),
      Double(size.width),
      Double(size.height)
    )
  }

  func pushEllipse(to canvasContext: JSObject) {
    _ = canvasContext.ellipse!(
      Double(origin.x + size.width / 2),
      Double(origin.y + size.height / 2),
      Double(size.width / 2),
      Double(size.height / 2),
      0,
      0,
      Double.pi * 2
    )
  }
}

private extension FixedRoundedRect {
  func push(to canvasContext: JSObject) {
    let cornerSize = cornerSize ?? CGSize(
      width: min(rect.size.width, rect.size.height) / 2,
      height: min(rect.size.width, rect.size.height) / 2
    ) // Capsule rounding
    _ = canvasContext.moveTo!(Double(rect.minX + cornerSize.width), Double(rect.minY))
    _ = canvasContext.lineTo!(Double(rect.maxX - cornerSize.width), Double(rect.minY))
    _ = canvasContext.quadraticCurveTo!(
      Double(rect.maxX),
      Double(rect.minY),
      Double(rect.maxX),
      Double(rect.minY + cornerSize.height)
    )
    _ = canvasContext.lineTo!(Double(rect.maxX), Double(rect.maxY - cornerSize.height))
    _ = canvasContext.quadraticCurveTo!(
      Double(rect.maxX),
      Double(rect.maxY),
      Double(rect.maxX - cornerSize.width),
      Double(rect.maxY)
    )
    _ = canvasContext.lineTo!(Double(rect.minX + cornerSize.width), Double(rect.maxY))
    _ = canvasContext.quadraticCurveTo!(
      Double(rect.minX),
      Double(rect.maxY),
      Double(rect.minX),
      Double(rect.maxY - cornerSize.height)
    )
    _ = canvasContext.lineTo!(Double(rect.minX), Double(rect.minY + cornerSize.height))
    _ = canvasContext.quadraticCurveTo!(
      Double(rect.minX),
      Double(rect.minY),
      Double(rect.minX + cornerSize.width),
      Double(rect.minY)
    )
  }
}
