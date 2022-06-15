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

import Foundation
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

private struct GradientID: Hashable {
  let stops: [StopID]

  init(_ gradient: Gradient) {
    stops = gradient.stops.map(StopID.init)
  }

  struct StopID: Hashable {
    let color: Color
    let location: CGFloat

    init(_ stop: Gradient.Stop) {
      color = stop.color
      location = stop.location
    }
  }
}

extension _ShapeView: _HTMLPrimitive {
  private func gradientID(for gradient: Gradient, in style: _GradientStyle) -> String {
    "gradient\(GradientID(gradient).hashValue)___\(style.hashValue)"
  }

  func attributes(resolvedStyle: _ResolvedStyle?) -> [HTMLAttribute: String] {
    if let shapeAttributes = shape as? ShapeAttributes {
      return shapeAttributes.attributes(style)
    } else {
      switch resolvedStyle {
      case let .gradient(gradient, style):

        if case .angular = style {
          return [:]
        } else {
          return ["style": "fill: url(#\(gradientID(for: gradient, in: style)));"]
        }
      default:
        if let color = resolvedStyle?.color(at: 0) {
          return ["style": "fill: \(color.cssValue(environment));"]
        } else if
          let foregroundStyle = environment._foregroundStyle,
          let color = foregroundStyle.resolve(
            for: .resolveStyle(levels: 0..<1),
            in: environment,
            role: Content.role
          )?.color(at: 0)
        {
          return ["style": "fill: \(color.cssValue(environment));"]
        } else {
          return [:]
        }
      }
    }
  }

  func svgDefinitions(resolvedStyle: _ResolvedStyle?)
    -> HTML<ForEach<[EnumeratedSequence<[Gradient.Stop]>.Element], Int, HTML<EmptyView>>>?
  {
    guard case let .gradient(gradient, style) = resolvedStyle else { return nil }
    let stops = ForEach(Array(gradient.stops.enumerated()), id: \.offset) {
      HTML("stop", namespace: namespace, [
        "offset": "\($0.element.location * 100)%",
        "stop-color": $0.element.color.cssValue(environment),
      ])
    }
    switch style {
    case let .linear(startPoint, endPoint):
      return HTML(
        "linearGradient",
        namespace: namespace,
        [
          "id": gradientID(for: gradient, in: style),
          "x1": "\(startPoint.x * 100)%",
          "y1": "\(startPoint.y * 100)%",
          "x2": "\(endPoint.x * 100)%",
          "y2": "\(endPoint.y * 100)%",
          "gradientUnits": "userSpaceOnUse",
        ]
      ) {
        stops
      }
    case let .radial(center, startRadius, endRadius):
      return HTML(
        "radialGradient",
        namespace: namespace,
        [
          "id": gradientID(for: gradient, in: style),
          "fx": "\(center.x * 100)%",
          "fy": "\(center.y * 100)%",
          "cx": "\(center.x * 100)%",
          "cy": "\(center.y * 100)%",
          "gradientUnits": "userSpaceOnUse",
          "fr": "\(startRadius)",
          "r": "\(endRadius)",
        ]
      ) {
        stops
      }
    default: return nil
    }
  }

  func cssGradient(resolvedStyle: _ResolvedStyle?) -> String? {
    guard case let .gradient(gradient, .angular(center, startAngle, endAngle)) = resolvedStyle
    else { return nil }
    let ratio = CGFloat((endAngle - startAngle).degrees / 360.0)
    var cssStops = gradient.stops.enumerated().map {
      $0.element.color.cssValue(environment) + " \($0.element.location * 100.0 * ratio)%"
    }
    if ratio < 1.0 && cssStops.count > 0 {
      cssStops
        .append("\(gradient.stops.last!.color.cssValue(environment)) \(50.0 + 50 * ratio)%")
      cssStops
        .append(
          "\(gradient.stops.first!.color.cssValue(environment)) \(50.0 + 50 * ratio)%"
        )
    }
    if cssStops.count == 1 {
      cssStops.append(cssStops[0])
    }
    return "background:conic-gradient(from \(startAngle.degrees + 90)deg at " +
      "\(center.x * 100)% \(center.y * 100)%, " +
      "\(cssStops.joined(separator: ", ")));"
  }

  @_spi(TokamakStaticHTML)
  public var renderedBody: AnyView {
    let path = shape.path(in: .zero).renderedBody

    let resolvedStyle = style.resolve(
      for: .resolveStyle(levels: 0..<1),
      in: environment,
      role: Content.role
    )

    if let view = mapAnyView(path, transform: { (html: HTML<HTML<EmptyView>?>) -> AnyView in
      let uniqueKeys = { (first: String, second: String) in "\(first) \(second)" }
      let mergedAttributes = html.attributes.merging(
        attributes(resolvedStyle: resolvedStyle),
        uniquingKeysWith: uniqueKeys
      )
      return AnyView(HTML(html.tag, mergedAttributes) {
        if let cssGradient = cssGradient(resolvedStyle: resolvedStyle) {
          HTML(
            "clipPath",
            namespace: namespace,
            ["id": "clip", "width": "100%", "height": "100%"]
          ) {
            html.content
          }
          HTML(
            "foreignObject",
            namespace: namespace,
            ["clip-path": "url(#clip)", "width": "100%", "height": "100%", "style": cssGradient]
          )
        } else {
          html.content
          if let svgDefs = svgDefinitions(resolvedStyle: resolvedStyle) {
            HTML("defs", namespace: namespace) {
              svgDefs
            }
          }
        }
      })
    }) {
      return view
    } else {
      return path
    }
  }
}

@_spi(TokamakStaticHTML)
extension _ShapeView: HTMLConvertible {
  public var tag: String { "svg" }
  public var namespace: String? { "http://www.w3.org/2000/svg" }
  public func attributes(useDynamicLayout: Bool) -> [HTMLAttribute: String] {
    let resolvedStyle = style.resolve(
      for: .resolveStyle(levels: 0..<1),
      in: environment,
      role: Content.role
    )
    return attributes(resolvedStyle: resolvedStyle)
  }

  public func primitiveVisitor<V>(useDynamicLayout: Bool) -> ((V) -> ())? where V: ViewVisitor {
    let resolvedStyle = style.resolve(
      for: .resolveStyle(levels: 0..<1),
      in: environment,
      role: Content.role
    )
    let path = shape.path(in: .zero).svgBody()
    return {
      if let cssGradient = cssGradient(resolvedStyle: resolvedStyle) {
        $0
          .visit(HTML(
            "clipPath",
            namespace: namespace,
            ["id": "clip", "width": "100%", "height": "100%"]
          ) {
            path
          })
        $0.visit(HTML(
          "foreignObject",
          namespace: namespace,
          [
            "clip-path": "url(#clip)",
            "width": "100%",
            "height": "100%",
            "style": cssGradient,
          ]
        ))
      } else {
        $0.visit(path)
        if let svgDefs = svgDefinitions(resolvedStyle: resolvedStyle) {
          $0.visit(HTML("defs", namespace: namespace) {
            svgDefs
          })
        }
      }
    }
  }
}
