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
//  Created by Carson Katri on 9/17/21.
//

import Foundation
import JavaScriptKit
import TokamakCore
import TokamakStaticHTML

private let devicePixelRatio = JSObject.global.devicePixelRatio.number ?? 1

private struct _Canvas<Symbols: View>: View {
  let parent: Canvas<Symbols>
  @StateObject private var coordinator = Coordinator()
  @Environment(\.inAnimatingTimelineView) private var inAnimatingTimelineView
  final class Coordinator: ObservableObject {
    @Published var canvas: JSObject?
    var currentDrawLoop: UUID?
  }

  var body: some View {
    GeometryReader { proxy in
      HTML("canvas", [
        "style": "width: 100%; height: 100%;",
      ])
        ._domRef($coordinator.canvas)
        .onAppear { draw(in: proxy.size) }
        ._onUpdate { draw(in: proxy.size) }
    }
  }

  private func draw(in size: CGSize) {
    let drawCallID = UUID()
    coordinator.currentDrawLoop = drawCallID
    guard let canvas = coordinator.canvas,
          let canvasContext = canvas.getContext!("2d").object
    else { return }
    // Setup the canvas size
    canvas.width = .number(Double(size.width * CGFloat(devicePixelRatio)))
    canvas.height = .number(Double(size.height * CGFloat(devicePixelRatio)))
    // Restore the initial state.
    _ = canvasContext.restore!()
    // Clear the canvas.
    _ = canvasContext.clearRect!(0, 0, canvas.width, canvas.height)
    // Save the cleared state for the next redraw to restore.
    _ = canvasContext.save!()
    // Scale for retina displays
    _ = canvasContext.scale!(devicePixelRatio, devicePixelRatio)
    // Create a fresh context.
    var graphicsContext = parent._makeContext(
      onOperation: { storage, operation in
        handleOperation(storage, operation, in: canvasContext)
      },
      imageResolver: resolveImage,
      textResolver: resolveText(in: canvasContext),
      symbolResolver: resolveSymbol
    )
    // Render into the context.
    parent.renderer(&graphicsContext, size)
    if inAnimatingTimelineView {
      _ = JSObject.global.requestAnimationFrame!(JSOneshotClosure { [weak coordinator] _ in
        guard coordinator?.currentDrawLoop == drawCallID else { return .undefined }
        draw(in: size)
        return .undefined
      })
    }
  }

  private func handleOperation(
    _ storage: GraphicsContext._Storage,
    _ operation: GraphicsContext._Storage._Operation,
    in canvasContext: JSObject
  ) {
    canvasContext.globalCompositeOperation = .string(storage.blendMode.cssValue)
    switch operation {
    case let .clip(path, _, _):
      pushPath(path, in: canvasContext)
      _ = canvasContext.clip!()
    case .beginClipLayer:
      break
    case .endClipLayer:
      _ = canvasContext.clip!()
    case let .addFilter(filter, _):
      applyFilter(filter, to: canvasContext)
    case .beginLayer:
      _ = canvasContext.save!()
    case .endLayer:
      _ = canvasContext.restore!()
    case let .fill(path, shading, fillStyle):
      _ = canvasContext.save!()
      pushPath(path, in: canvasContext)
      canvasContext.fillStyle = shading.cssValue(
        in: parent._environment,
        with: canvasContext,
        bounds: path.boundingRect
      )
      _ = canvasContext.fill!(fillStyle.isEOFilled ? "evenodd" : "nonzero")
      _ = canvasContext.restore!()
    case let .stroke(path, shading, strokeStyle):
      _ = canvasContext.save!()
      pushPath(path, in: canvasContext)
      canvasContext.strokeStyle = shading.cssValue(
        in: parent._environment,
        with: canvasContext,
        bounds: path.boundingRect
      )
      canvasContext.lineWidth = .number(Double(strokeStyle.lineWidth))
      _ = canvasContext.stroke!()
      _ = canvasContext.restore!()
    case .drawImage:
      break
    case let .drawText(text, positioning):
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
    case let .drawSymbol(symbol, positioning):
      // Create an SVG element containing the View's rendered HTML. This was resolved to SVG earlier.
      let img = JSObject.global.Image.function!.new()
      let svgData = JSObject.global.Blob.function!.new(
        [symbol._resolved as? String ?? ""],
        ["type": "image/svg+xml;charset=utf-8"]
      )
      // Create a URL to the SVG data.
      let objectURL = JSObject.global.URL.function!.createObjectURL!(svgData)

      img.onload = .object(JSOneshotClosure { _ in
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
            Double(point.y - (anchor.y * symbol.size.width))
          )
        }
        _ = JSObject.global.URL.function!.revokeObjectURL!(objectURL)
        return .undefined
      })

      img.src = objectURL
    }
  }

  private func resolveImage(_ image: Image, _ environment: EnvironmentValues) -> GraphicsContext
    .ResolvedImage
  {
    ._resolved(image, size: .zero, baseline: 0)
  }

  private func resolveText(in canvasContext: JSObject)
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

  private func resolveSymbol(
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
      )
      .renderRoot(),
      size: size
    )
  }

  private func applyFilter(_ filter: GraphicsContext.Filter, to canvasContext: JSObject) {
    let previousFilter = canvasContext.filter
      .string == "none" ? "" : (canvasContext.filter.string ?? "")
    switch filter._storage {
    case let .projectionTransform(matrix):
      _ = canvasContext.transform!(
        Double(matrix.m11), Double(matrix.m12),
        Double(matrix.m21), Double(matrix.m22),
        Double(matrix.m31), Double(matrix.m32)
      )
    case let .shadow(color, radius, x, y, _, _):
      canvasContext
        .shadowColor = .string(
          _ColorProxy(color).resolve(in: parent._environment)
            .cssValue
        )
      canvasContext.shadowBlur = .number(Double(radius))
      canvasContext.shadowOffsetX = .number(Double(x))
      canvasContext.shadowOffsetY = .number(Double(y))
    case .colorMultiply:
      break
    case .colorMatrix:
      break
    case let .hueRotation(angle):
      canvasContext.filter = .string("\(previousFilter) hue-rotate(\(angle.radians)rad)")
    case let .saturation(amount):
      canvasContext.filter = .string("\(previousFilter) saturate(\(amount * 100)%)")
    case let .brightness(amount):
      canvasContext.filter = .string("\(previousFilter) brightness(\(amount * 100)%)")
    case let .contrast(amount):
      canvasContext.filter = .string("\(previousFilter) contrast(\(amount * 100)%)")
    case let .colorInvert(amount):
      canvasContext.filter = .string("\(previousFilter) invert(\(amount * 100)%)")
    case let .grayscale(amount):
      canvasContext.filter = .string("\(previousFilter) grayscale(\(amount * 100)%)")
    case .luminanceToAlpha:
      break
    case let .blur(radius, _):
      canvasContext.filter = .string("\(previousFilter) blur(\(radius)px)")
    case .alphaThreshold:
      break
    }
  }

  private func pushPath(_ path: Path, in canvasContext: JSObject) {
    _ = canvasContext.beginPath!()
    switch path.storage {
    case let .rect(rect):
      _ = canvasContext.rect!(
        Double(rect.origin.x),
        Double(rect.origin.y),
        Double(rect.size.width),
        Double(rect.size.height)
      )
    case let .ellipse(rect):
      _ = canvasContext.ellipse!(
        Double(rect.origin.x + rect.size.width / 2),
        Double(rect.origin.y + rect.size.height / 2),
        Double(rect.size.width / 2),
        Double(rect.size.height / 2),
        0,
        0,
        Double.pi * 2
      )
    case let .roundedRect(rect):
      let cornerSize = rect.cornerSize ?? CGSize(
        width: min(rect.rect.size.width, rect.rect.size.height) / 2,
        height: min(rect.rect.size.width, rect.rect.size.height) / 2
      ) // Capsule rounding
      _ = canvasContext.moveTo!(Double(rect.rect.minX + cornerSize.width), Double(rect.rect.minY))
      _ = canvasContext.lineTo!(Double(rect.rect.maxX - cornerSize.width), Double(rect.rect.minY))
      _ = canvasContext.quadraticCurveTo!(
        Double(rect.rect.maxX),
        Double(rect.rect.minY),
        Double(rect.rect.maxX),
        Double(rect.rect.minY + cornerSize.height)
      )
      _ = canvasContext.lineTo!(Double(rect.rect.maxX), Double(rect.rect.maxY - cornerSize.height))
      _ = canvasContext.quadraticCurveTo!(
        Double(rect.rect.maxX),
        Double(rect.rect.maxY),
        Double(rect.rect.maxX - cornerSize.width),
        Double(rect.rect.maxY)
      )
      _ = canvasContext.lineTo!(Double(rect.rect.minX + cornerSize.width), Double(rect.rect.maxY))
      _ = canvasContext.quadraticCurveTo!(
        Double(rect.rect.minX),
        Double(rect.rect.maxY),
        Double(rect.rect.minX),
        Double(rect.rect.maxY - cornerSize.height)
      )
      _ = canvasContext.lineTo!(Double(rect.rect.minX), Double(rect.rect.minY + cornerSize.height))
      _ = canvasContext.quadraticCurveTo!(
        Double(rect.rect.minX),
        Double(rect.rect.minY),
        Double(rect.rect.minX + cornerSize.width),
        Double(rect.rect.minY)
      )
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
          _ = canvasContext.closePath!()
          _ = canvasContext.beginPath!()
        }
      }
    default:
      print("TODO: push \(path) (\(path.storage))")
    }
    _ = canvasContext.closePath!()
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
        "\(style) \(variant) \(weight) \(size ?? "17")pt \(lineHeight) \(family ?? Font.Design.default.families.joined(separator: " "))"
      )
  }
}

extension Canvas: DOMPrimitive {
  public var renderedBody: AnyView {
    AnyView(_Canvas(parent: self))
  }
}

private extension GraphicsContext.Shading {
  func cssValue(in environment: EnvironmentValues, with canvas: JSObject,
                bounds: CGRect) -> JSValue
  {
    if case let .resolved(resolved) = _resolve(in: environment)._storage {
      return resolved.cssValue(in: environment, with: canvas, bounds: bounds)
    }
    return .string("none")
  }
}

private extension GraphicsContext._ResolvedShading {
  func cssValue(in environment: EnvironmentValues, with canvas: JSObject,
                bounds: CGRect) -> JSValue
  {
    switch self {
    case let .levels(palette):
      guard let primary = palette.first else { break }
      return primary.cssValue(in: environment, with: canvas, bounds: bounds)
    case let .style(style):
      return style.cssValue(in: environment, with: canvas, bounds: bounds)
    case let .gradient(gradient, geometry, _):
      let gradientBounds = CGRect(origin: .zero, size: .init(width: 1, height: 1))
      switch geometry {
      case let .axial(startPoint, endPoint):
        return _ResolvedStyle.gradient(
          gradient,
          style: .linear(
            startPoint: .init(x: startPoint.x, y: startPoint.y),
            endPoint: .init(x: endPoint.x, y: endPoint.y)
          )
        ).cssValue(in: environment, with: canvas, bounds: gradientBounds)
      case let .conic(center, angle):
        return _ResolvedStyle.gradient(
          gradient,
          style: .angular(
            center: .init(x: center.x, y: center.y),
            startAngle: .degrees(0),
            endAngle: angle
          )
        ).cssValue(in: environment, with: canvas, bounds: gradientBounds)
      case let .radial(center, startRadius, endRadius):
        return _ResolvedStyle.gradient(
          gradient,
          style: .radial(
            center: .init(x: center.x, y: center.y),
            startRadius: startRadius,
            endRadius: endRadius
          )
        ).cssValue(in: environment, with: canvas, bounds: gradientBounds)
      }
    case .tiledImage:
      break
    }
    return .string("none")
  }
}

private extension _ResolvedStyle {
  func cssValue(
    in environment: EnvironmentValues,
    opacity: Float = 1,
    with canvas: JSObject,
    bounds: CGRect
  ) -> JSValue {
    switch self {
    case let .color(color):
      return .string(AnyColorBox.ResolvedValue(
        red: color.red,
        green: color.green,
        blue: color.blue,
        opacity: color.opacity * Double(opacity),
        space: color.space
      ).cssValue)
    case .foregroundMaterial:
      break
    case let .array(palette):
      guard let primary = palette.first else { break }
      return primary.cssValue(in: environment, opacity: opacity, with: canvas, bounds: bounds)
    case let .opacity(opacity, style):
      return style.cssValue(in: environment, opacity: opacity, with: canvas, bounds: bounds)
    case let .gradient(gradient, style):
      let canvasGradient: JSObject
      switch style {
      case let .linear(startPoint, endPoint):
        canvasGradient = canvas.createLinearGradient!(
          Double(bounds.origin.x + startPoint.x * bounds.width),
          Double(bounds.origin.y + startPoint.y * bounds.height),
          Double(bounds.origin.x + endPoint.x * bounds.width),
          Double(bounds.origin.y + endPoint.y * bounds.height)
        ).object!
      case let .radial(center, startRadius, endRadius):
        canvasGradient = canvas.createRadialGradient!(
          Double(bounds.origin.x + center.x * bounds.width),
          Double(bounds.origin.y + center.y * bounds.height),
          Double(startRadius),
          Double(bounds.origin.x + center.x * bounds.width),
          Double(bounds.origin.y + center.y * bounds.height),
          Double(endRadius)
        ).object!
      case let .elliptical(center, startRadiusFraction, endRadiusFraction):
        canvasGradient = canvas.createRadialGradient!(
          Double(bounds.origin.x + center.x * bounds.width),
          Double(bounds.origin.y + center.y * bounds.height),
          Double(startRadiusFraction * bounds.width),
          Double(bounds.origin.x + center.x * bounds.width),
          Double(bounds.origin.y + center.y * bounds.height),
          Double(endRadiusFraction * bounds.width)
        ).object!
      case let .angular(center, _, endAngle):
        canvasGradient = canvas.createConicGradient!(
          Double(endAngle.radians),
          Double(bounds.origin.x + center.x * bounds.width),
          Double(bounds.origin.y + center.y * bounds.height)
        ).object!
      }
      for stop in gradient.stops {
        _ = canvasGradient.addColorStop!(
          Double(stop.location),
          _ColorProxy(stop.color).resolve(in: environment).cssValue
        )
      }
      return .object(canvasGradient)
    }
    return .string("")
  }
}

private extension GraphicsContext.BlendMode {
  var cssValue: String {
    switch self {
    case .normal: return "normal"
    case .multiply: return "multiply"
    case .screen: return "screen"
    case .overlay: return "overlay"
    case .darken: return "darken"
    case .lighten: return "lighten"
    case .colorDodge: return "color-dodge"
    case .colorBurn: return "color-burn"
    case .softLight: return "soft-light"
    case .hardLight: return "hard-light"
    case .difference: return "difference"
    case .exclusion: return "exclusion"
    case .hue: return "hue"
    case .saturation: return "saturation"
    case .color: return "color"
    case .luminosity: return "luminosity"
    case .clear: return "clear"
    case .copy: return "copy"
    case .sourceIn: return "source-in"
    case .sourceOut: return "source-out"
    case .sourceAtop: return "source-atop"
    case .destinationOver: return "destination-over"
    case .destinationIn: return "destination-in"
    case .destinationOut: return "destination-out"
    case .destinationAtop: return "destination-atop"
    case .xor: return "xor"
    case .plusDarker: return "darken"
    case .plusLighter: return "lighten"
    }
  }
}
