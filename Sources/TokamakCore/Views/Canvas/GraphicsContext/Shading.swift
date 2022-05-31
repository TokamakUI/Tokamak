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
  enum _GradientGeometry {
    case axial(CGPoint, CGPoint)
    case conic(CGPoint, Angle)
    case radial(CGPoint, CGFloat, CGFloat)
  }

  enum _ResolvedShading {
    case levels([Self])
    case style(_ResolvedStyle)
    case gradient(Gradient, geometry: _GradientGeometry, options: GradientOptions)
    case tiledImage(
      Image,
      origin: CGPoint = .zero,
      sourceRect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1),
      scale: CGFloat = 1
    )
  }

  struct Shading {
    public enum _Storage {
      case backdrop
      case foreground
      case levels([Shading])
      case color(Color)
      case style(ShapeStyle)
      case gradient(Gradient, geometry: _GradientGeometry, options: GradientOptions)
      case tiledImage(
        Image,
        origin: CGPoint = .zero,
        sourceRect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1),
        scale: CGFloat = 1
      )
      case resolved(_ResolvedShading)
    }

    public let _storage: _Storage

    fileprivate init(_ storage: _Storage) {
      _storage = storage
    }

    public func _resolve(in environment: EnvironmentValues) -> Self {
      switch _storage {
      case .backdrop:
        return Self.style(BackgroundStyle())._resolve(in: environment)
      case .foreground:
        return Self.style(ForegroundStyle())._resolve(in: environment)
      case let .levels(colors):
        return .init(.resolved(.levels(colors.compactMap {
          guard case let .resolved(resolved) = $0._resolve(in: environment)._storage
          else { return nil }
          return resolved
        })))
      case let .color(color):
        return Self.style(color)._resolve(in: environment)
      case let .style(shapeStyle):
        var shape = _ShapeStyle_Shape(
          for: .resolveStyle(levels: 0..<1),
          in: environment,
          role: .fill
        )
        shapeStyle._apply(to: &shape)
        guard let style = shape.result.resolvedStyle(on: shape, in: environment)
        else {
          return .init(.resolved(.style(.color(.init(
            red: 0,
            green: 0,
            blue: 0,
            opacity: 1,
            space: .sRGB
          )))))
        }
        return .init(.resolved(.style(style)))
      case let .gradient(gradient, geometry, options):
        return .init(.resolved(.gradient(gradient, geometry: geometry, options: options)))
      case let .tiledImage(image, origin, sourceRect, scale):
        return .init(.resolved(.tiledImage(
          image,
          origin: origin,
          sourceRect: sourceRect,
          scale: scale
        )))
      case .resolved:
        return self
      }
    }

    public static var backdrop: Shading { .init(.backdrop) }
    public static var foreground: Shading { .init(.foreground) }

    public static func palette(_ array: [Shading]) -> Shading { .init(.levels(array)) }

    public static func color(_ color: Color) -> Shading { .init(.color(color)) }
    public static func color(
      _ colorSpace: Color.RGBColorSpace = .sRGB,
      red: Double,
      green: Double,
      blue: Double,
      opacity: Double = 1
    ) -> Shading {
      .init(.color(Color(colorSpace, red: red, green: green, blue: blue, opacity: opacity)))
    }

    public static func color(
      _ colorSpace: Color.RGBColorSpace = .sRGB,
      white: Double,
      opacity: Double = 1
    ) -> Shading {
      .init(.color(Color(colorSpace, white: white, opacity: opacity)))
    }

    public static func style<S>(_ style: S) -> Shading where S: ShapeStyle {
      .init(.style(style))
    }

    public static func linearGradient(
      _ gradient: Gradient,
      startPoint: CGPoint,
      endPoint: CGPoint,
      options: GradientOptions = GradientOptions()
    ) -> Shading {
      .init(.gradient(gradient, geometry: .axial(startPoint, endPoint), options: options))
    }

    public static func radialGradient(
      _ gradient: Gradient,
      center: CGPoint,
      startRadius: CGFloat,
      endRadius: CGFloat,
      options: GradientOptions = GradientOptions()
    ) -> Shading {
      .init(.gradient(
        gradient,
        geometry: .radial(center, startRadius, endRadius),
        options: options
      ))
    }

    public static func conicGradient(
      _ gradient: Gradient,
      center: CGPoint,
      angle: Angle = Angle(),
      options: GradientOptions = GradientOptions()
    ) -> Shading {
      .init(.gradient(gradient, geometry: .conic(center, angle), options: options))
    }

    public static func tiledImage(
      _ image: Image,
      origin: CGPoint = .zero,
      sourceRect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1),
      scale: CGFloat = 1
    ) -> Shading {
      .init(.tiledImage(image, origin: origin, sourceRect: sourceRect, scale: scale))
    }
  }

  @frozen
  struct GradientOptions: OptionSet {
    public let rawValue: UInt32

    @inlinable
    public init(rawValue: UInt32) { self.rawValue = rawValue }

    @inlinable
    public static var `repeat`: Self { Self(rawValue: 1 << 0) }

    @inlinable
    public static var mirror: Self { Self(rawValue: 1 << 1) }

    @inlinable
    public static var linearColor: Self { Self(rawValue: 1 << 2) }
  }

  func resolve(_ shading: Shading) -> Shading {
    shading._resolve(in: _storage.environment)
  }
}
