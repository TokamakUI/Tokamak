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
//  Created by Carson Katri on 9/18/21.
//

import Foundation

public struct GraphicsContext {
  public struct _Storage {
    public var opacity: Double
    public var blendMode: BlendMode
    public var environment: EnvironmentValues
    public var transform: CGAffineTransform
    public var clipBoundingRect: CGRect

    public var operationHandler: (Self, _Operation) -> ()
    public var imageResolver: (Image, EnvironmentValues) -> ResolvedImage
    public var textResolver: (Text, EnvironmentValues) -> ResolvedText
    let symbols: AnyView
    public var symbolResolver: (AnyHashable, AnyView, EnvironmentValues) -> ResolvedSymbol

    init(
      in environment: EnvironmentValues,
      with operationHandler: @escaping (Self, _Operation) -> (),
      imageResolver: @escaping (Image, EnvironmentValues) -> ResolvedImage,
      textResolver: @escaping (Text, EnvironmentValues) -> ResolvedText,
      symbols: AnyView,
      symbolResolver: @escaping (AnyHashable, AnyView, EnvironmentValues) -> ResolvedSymbol
    ) {
      opacity = 1
      blendMode = .normal
      self.environment = environment
      transform = .identity
      clipBoundingRect = .zero
      self.operationHandler = operationHandler
      self.imageResolver = imageResolver
      self.textResolver = textResolver
      self.symbols = symbols
      self.symbolResolver = symbolResolver
    }

    public func perform(_ operation: _Operation) {
      operationHandler(self, operation)
    }

    public enum _Operation {
      case clip(Path, style: FillStyle, options: ClipOptions)
      case beginClipLayer(GraphicsContext, opacity: Double)
      case endClipLayer
      case addFilter(Filter, options: FilterOptions)
      case beginLayer(GraphicsContext)
      case endLayer
      case fill(Path, with: Shading, style: FillStyle)
      case stroke(Path, with: Shading, style: StrokeStyle)
      case drawImage(ResolvedImage, _ResolvedPositioning, style: FillStyle? = .init())
      case drawText(ResolvedText, _ResolvedPositioning)
      case drawSymbol(ResolvedSymbol, _ResolvedPositioning)

      public enum _ResolvedPositioning {
        case `in`(CGRect)
        case at(CGPoint, anchor: UnitPoint = .center)
      }
    }
  }

  public var _storage: _Storage

  public var opacity: Double {
    get { _storage.opacity }
    set { _storage.opacity = newValue }
  }

  public var blendMode: BlendMode {
    get { _storage.blendMode }
    set { _storage.blendMode = newValue }
  }

  public var environment: EnvironmentValues {
    get { _storage.environment }
    set { _storage.environment = newValue }
  }

  public var transform: CGAffineTransform {
    get { _storage.transform }
    set { _storage.transform = newValue }
  }

  public mutating func scaleBy(x: CGFloat, y: CGFloat) {
    addFilter(.projectionTransform(.init(.init(scaleX: x, y: y))))
  }

  public mutating func translateBy(x: CGFloat, y: CGFloat) {
    addFilter(.projectionTransform(.init(.init(translationX: x, y: y))))
  }

  public mutating func rotate(by angle: Angle) {
    addFilter(.projectionTransform(.init(.init(rotationAngle: CGFloat(angle.radians)))))
  }

  public mutating func concatenate(_ matrix: CGAffineTransform) {
    addFilter(.projectionTransform(.init(matrix)))
  }

  @frozen
  public struct ClipOptions: OptionSet {
    public let rawValue: UInt32

    @inlinable
    public init(rawValue: UInt32) { self.rawValue = rawValue }

    @inlinable
    public static var inverse: Self { Self(rawValue: 1 << 0) }
  }

  public var clipBoundingRect: CGRect {
    get { _storage.clipBoundingRect }
    set { _storage.clipBoundingRect = newValue }
  }

  public mutating func clip(
    to path: Path,
    style: FillStyle = FillStyle(),
    options: ClipOptions = ClipOptions()
  ) {
    _storage.perform(.clip(path, style: style, options: options))
  }

  public mutating func clipToLayer(
    opacity: Double = 1,
    options: ClipOptions = ClipOptions(),
    content: (inout GraphicsContext) throws -> ()
  ) rethrows {
    var layer = GraphicsContext(_storage: _storage)
    _storage.perform(.beginClipLayer(layer, opacity: opacity))
    try content(&layer)
    _storage.perform(.endClipLayer)
  }

  public func drawLayer(content: (inout GraphicsContext) throws -> ()) rethrows {
    var layer = GraphicsContext(_storage: _storage)
    _storage.perform(.beginLayer(layer))
    try content(&layer)
    _storage.perform(.endLayer)
  }

  public func fill(_ path: Path, with shading: Shading, style: FillStyle = FillStyle()) {
    _storage.perform(.fill(path, with: shading, style: style))
  }

  public func stroke(_ path: Path, with shading: Shading, style: StrokeStyle) {
    _storage.perform(.stroke(path, with: shading, style: style))
  }

  public func stroke(_ path: Path, with shading: Shading, lineWidth: CGFloat = 1) {
    stroke(path, with: shading, style: .init(lineWidth: lineWidth))
  }

//  public func withCGContext(content: (CGContext) throws -> ()) rethrows
}
