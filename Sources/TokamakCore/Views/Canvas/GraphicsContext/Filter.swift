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

public extension GraphicsContext {
  struct Filter {
    public let _storage: _Storage

    private init(_ storage: _Storage) {
      _storage = storage
    }

    public enum _Storage {
      case projectionTransform(ProjectionTransform)
      case shadow(
        color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33),
        radius: CGFloat,
        x: CGFloat = 0,
        y: CGFloat = 0,
        blendMode: BlendMode = .normal,
        options: ShadowOptions = ShadowOptions()
      )
      case colorMultiply(Color)
      case colorMatrix(ColorMatrix)
      case hueRotation(Angle)
      case saturation(Double)
      case brightness(Double)
      case contrast(Double)
      case colorInvert(Double = 1)
      case grayscale(Double)
      case luminanceToAlpha
      case blur(
        radius: CGFloat,
        options: BlurOptions = .opaque
      )
      case alphaThreshold(
        min: Double,
        max: Double = 1,
        color: Color = Color.black
      )
    }

    public static func projectionTransform(_ matrix: ProjectionTransform) -> Self {
      .init(.projectionTransform(matrix))
    }

    public static func shadow(
      color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33),
      radius: CGFloat,
      x: CGFloat = 0,
      y: CGFloat = 0,
      blendMode: BlendMode = .normal,
      options: ShadowOptions = ShadowOptions()
    ) -> Self {
      .init(.shadow(
        color: color,
        radius: radius,
        x: x,
        y: y,
        blendMode: blendMode,
        options: options
      ))
    }

    public static func colorMultiply(_ color: Color) -> Self {
      .init(.colorMultiply(color))
    }

    public static func colorMatrix(_ matrix: ColorMatrix) -> Self {
      .init(.colorMatrix(matrix))
    }

    public static func hueRotation(_ angle: Angle) -> Self {
      .init(.hueRotation(angle))
    }

    public static func saturation(_ amount: Double) -> Self {
      .init(.saturation(amount))
    }

    public static func brightness(_ amount: Double) -> Self {
      .init(.brightness(amount))
    }

    public static func contrast(_ amount: Double) -> Self {
      .init(.contrast(amount))
    }

    public static func colorInvert(_ amount: Double = 1) -> Self {
      .init(.colorInvert(amount))
    }

    public static func grayscale(_ amount: Double) -> Self {
      .init(.grayscale(amount))
    }

    public static var luminanceToAlpha: Self {
      .init(.luminanceToAlpha)
    }

    public static func blur(
      radius: CGFloat,
      options: BlurOptions = BlurOptions()
    ) -> Filter {
      .init(.blur(radius: radius, options: options))
    }

    public static func alphaThreshold(
      min: Double,
      max: Double = 1,
      color: Color = Color.black
    ) -> Filter {
      .init(.alphaThreshold(min: min, max: max, color: color))
    }
  }

  @frozen
  struct ShadowOptions: OptionSet {
    public let rawValue: UInt32

    @inlinable
    public init(rawValue: UInt32) { self.rawValue = rawValue }

    @inlinable
    public static var shadowAbove: Self { Self(rawValue: 1 << 0) }

    @inlinable
    public static var shadowOnly: Self { Self(rawValue: 1 << 1) }

    @inlinable
    public static var invertsAlpha: Self { Self(rawValue: 1 << 2) }

    @inlinable
    public static var disablesGroup: Self { Self(rawValue: 1 << 3) }
  }

  @frozen
  struct BlurOptions: OptionSet {
    public let rawValue: UInt32

    @inlinable
    public init(rawValue: UInt32) { self.rawValue = rawValue }

    @inlinable
    public static var opaque: Self { Self(rawValue: 1 << 0) }

    @inlinable
    public static var dithersResult: Self { Self(rawValue: 1 << 1) }
  }

  @frozen
  struct FilterOptions: OptionSet {
    public let rawValue: UInt32

    @inlinable
    public init(rawValue: UInt32) { self.rawValue = rawValue }

    @inlinable
    public static var linearColor: Self { Self(rawValue: 1 << 0) }
  }

  mutating func addFilter(
    _ filter: Filter,
    options: FilterOptions = FilterOptions()
  ) {
    _storage.perform(.addFilter(filter, options: options))
  }
}
