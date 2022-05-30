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

public struct Canvas<Symbols> where Symbols: View {
  public var symbols: Symbols
  public var renderer: (inout GraphicsContext, CGSize) -> ()
  public var isOpaque: Bool
  public var colorMode: ColorRenderingMode
  public var rendersAsynchronously: Bool

  @Environment(\.self)
  public var _environment: EnvironmentValues

  public func _makeContext(
    onOperation: @escaping (GraphicsContext._Storage, GraphicsContext._Storage._Operation) -> (),
    imageResolver: @escaping (Image, EnvironmentValues) -> GraphicsContext.ResolvedImage,
    textResolver: @escaping (Text, EnvironmentValues) -> GraphicsContext.ResolvedText,
    symbolResolver: @escaping (AnyHashable, AnyView, EnvironmentValues) -> GraphicsContext
      .ResolvedSymbol
  ) -> GraphicsContext {
    .init(_storage: .init(
      in: _environment,
      with: onOperation,
      imageResolver: imageResolver,
      textResolver: textResolver,
      symbols: AnyView(symbols),
      symbolResolver: symbolResolver
    ))
  }

  public init(
    opaque: Bool = false,
    colorMode: ColorRenderingMode = .nonLinear,
    rendersAsynchronously: Bool = false,
    renderer: @escaping (inout GraphicsContext, CGSize) -> (),
    @ViewBuilder symbols: () -> Symbols
  ) {
    isOpaque = opaque
    self.colorMode = colorMode
    self.rendersAsynchronously = rendersAsynchronously
    self.renderer = renderer
    self.symbols = symbols()
  }
}

extension Canvas: _PrimitiveView {}

public extension Canvas where Symbols == EmptyView {
  init(
    opaque: Bool = false,
    colorMode: ColorRenderingMode = .nonLinear,
    rendersAsynchronously: Bool = false,
    renderer: @escaping (inout GraphicsContext, CGSize) -> ()
  ) {
    isOpaque = opaque
    self.colorMode = colorMode
    self.rendersAsynchronously = rendersAsynchronously
    self.renderer = renderer
    symbols = EmptyView()
  }
}

public enum ColorRenderingMode: Hashable {
  case nonLinear
  case linear
  case extendedLinear
}

public struct ColorMatrix: Equatable {
  public var r1: Float = 1, r2: Float = 0, r3: Float = 0, r4: Float = 0, r5: Float = 0
  public var g1: Float = 0, g2: Float = 1, g3: Float = 0, g4: Float = 0, g5: Float = 0
  public var b1: Float = 0, b2: Float = 0, b3: Float = 1, b4: Float = 0, b5: Float = 0
  public var a1: Float = 0, a2: Float = 0, a3: Float = 0, a4: Float = 1, a5: Float = 0

  @inlinable
  public init() {}
}

public struct _ColorMatrix: Equatable, Codable {
  public var m11: Float = 1, m12: Float = 0, m13: Float = 0, m14: Float = 0, m15: Float = 0
  public var m21: Float = 0, m22: Float = 1, m23: Float = 0, m24: Float = 0, m25: Float = 0
  public var m31: Float = 0, m32: Float = 0, m33: Float = 1, m34: Float = 0, m35: Float = 0
  public var m41: Float = 0, m42: Float = 0, m43: Float = 0, m44: Float = 1, m45: Float = 0

  @inlinable
  public init() {}

  public init(color: Color, in environment: EnvironmentValues) {
    m11 = 0
    m15 = Float(color.provider.resolve(in: environment).red / 255)
    m22 = 0
    m25 = Float(color.provider.resolve(in: environment).green / 255)
    m33 = 0
    m35 = Float(color.provider.resolve(in: environment).blue / 255)
    m44 = 0
    m45 = Float(color.provider.resolve(in: environment).opacity / 255)
  }
}
