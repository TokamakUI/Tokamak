// Copyright 2020 Tokamak contributors
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
//  Created by Carson Katri on 6/29/20.
//

import TokamakCore

protocol ShapeAttributes {
  func attributes(_ style: ShapeStyle) -> [HTMLAttribute: String]
}

extension ShapeStyle {
  func resolve(
    for operation: _ShapeStyle_Shape.Operation,
    in environment: EnvironmentValues,
    role: ShapeRole
  ) -> _ResolvedStyle? {
    var shape = _ShapeStyle_Shape(
      for: operation,
      in: environment,
      role: role
    )
    _apply(to: &shape)
    return shape.result
      .resolvedStyle(on: shape, in: environment)
  }
}

extension _StrokedShape: ShapeAttributes {
  func attributes(_ style: ShapeStyle) -> [HTMLAttribute: String] {
    if let color = style.resolve(
      for: .resolveStyle(levels: 0..<1),
      in: environment,
      role: .stroke
    )?.color(at: 0) {
      return ["style": "stroke: \(color.cssValue(environment)); fill: none;"]
    } else {
      return ["style": "stroke: black; fill: none;"]
    }
  }
}

extension _ShapeView: _HTMLPrimitive {
  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    let path = shape.path(in: .zero).renderedBody
    var attributes: [HTMLAttribute: String] = [:]
    var svgDefs: AnyView?

    if let shapeAttributes = shape as? ShapeAttributes {
      attributes = shapeAttributes.attributes(style)
    } else {
      let resolved = style.resolve(
        for: .resolveStyle(levels: 0..<1),
        in: environment,
        role: Content.role
      )
      switch resolved {
      case let .gradient(gradient, style):
        let stops = ForEach(Array(gradient.stops.enumerated()), id: \.offset) {
          HTML("stop", [
            "offset": "\($0.element.location * 100)%",
            "stop-color": $0.element.color.cssValue(environment),
          ])
        }
        let id = Int.random(in: 0..<Int.max)
        attributes = ["style": "fill: url(#gradient\(id));"]
        switch style {
        case let .linear(startPoint, endPoint):
          svgDefs = AnyView(HTML(
            "linearGradient",
            [
              "id": "gradient\(id)",
              "x1": "\(startPoint.x * 100)%",
              "y1": "\((1 - startPoint.y) * 100)%",
              "x2": "\(endPoint.x * 100)%",
              "y2": "\((1 - endPoint.y) * 100)%",
              "gradientUnits": "userSpaceOnUse",
            ]
          ) {
            stops
          })
        case let .radial(center, startRadius, endRadius):
          svgDefs = AnyView(
            HTML(
              "radialGradient",
              [
                "id": "gradient\(id)",
                "fx": "\(center.x * 100)%",
                "fy": "\((1 - center.y) * 100)%",
                "cx": "\(center.x * 100)%",
                "cy": "\((1 - center.y) * 100)%",
                "gradientUnits": "userSpaceOnUse",
                "fr": "\(startRadius)",
                "r": "\(endRadius)",
              ]
            ) {
              stops
            }
          )
        default: return path
        }
      default:
        if let color = resolved?.color(at: 0) {
          attributes = ["style": "fill: \(color.cssValue(environment));"]
        } else if let foregroundStyle = environment._foregroundStyle,
                  let color = foregroundStyle.resolve(
                    for: .resolveStyle(levels: 0..<1),
                    in: environment,
                    role: Content.role
                  )?.color(at: 0)
        {
          attributes = ["style": "fill: \(color.cssValue(environment));"]
        } else {
          return path
        }
      }
    }

    if let view = mapAnyView(path, transform: { (html: HTML<AnyView>) -> AnyView in
      let uniqueKeys = { (first: String, second: String) in "\(first) \(second)" }
      let mergedAttributes = html.attributes.merging(
        attributes,
        uniquingKeysWith: uniqueKeys
      )
      return AnyView(HTML(html.tag, mergedAttributes) {
        html.content
        HTML("defs") {
          svgDefs
        }
      })
    }) {
      return view
    } else {
      return path
    }
  }
}
