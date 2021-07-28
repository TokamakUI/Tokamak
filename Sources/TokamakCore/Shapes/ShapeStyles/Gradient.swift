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
//  Created by Carson Katri on 7/28/21.
//

import Foundation

@frozen public struct Gradient: Equatable {
  @frozen public struct Stop: Equatable {
    public var color: Color
    public var location: CGFloat

    public init(color: Color, location: CGFloat) {
      self.color = color
      self.location = location
    }
  }

  public var stops: [Gradient.Stop]

  public init(stops: [Gradient.Stop]) {
    self.stops = stops
  }

  public init(colors: [Color]) {
    stops = colors.enumerated().map {
      .init(
        color: $0.element,
        location: CGFloat($0.offset) / CGFloat(colors.count - 1)
      )
    }
  }
}

public enum _GradientStyle: Hashable {
  case linear(startPoint: UnitPoint, endPoint: UnitPoint)
  case radial(
    center: UnitPoint,
    startRadius: CGFloat,
    endRadius: CGFloat
  )
  case elliptical(
    center: UnitPoint,
    startRadiusFraction: CGFloat,
    endRadiusFraction: CGFloat
  )
  case angular(
    center: UnitPoint,
    startAngle: Angle,
    endAngle: Angle
  )
}

@frozen public struct LinearGradient: ShapeStyle, View {
  internal var gradient: Gradient
  internal var startPoint: UnitPoint
  internal var endPoint: UnitPoint

  public init(gradient: Gradient, startPoint: UnitPoint, endPoint: UnitPoint) {
    self.gradient = gradient
    self.startPoint = startPoint
    self.endPoint = endPoint
  }

  public init(colors: [Color], startPoint: UnitPoint, endPoint: UnitPoint) {
    self.init(
      gradient: Gradient(colors: colors),
      startPoint: startPoint, endPoint: endPoint
    )
  }

  public init(stops: [Gradient.Stop], startPoint: UnitPoint, endPoint: UnitPoint) {
    self.init(
      gradient: Gradient(stops: stops),
      startPoint: startPoint, endPoint: endPoint
    )
  }

  public typealias Body = _ShapeView<Rectangle, Self>

  public func _apply(to shape: inout _ShapeStyle_Shape) {
    shape.result = .resolved(
      .gradient(gradient, style: .linear(startPoint: startPoint, endPoint: endPoint))
    )
  }

  public static func _apply(to type: inout _ShapeStyle_ShapeType) {}
}

@frozen public struct RadialGradient: ShapeStyle, View {
  internal var gradient: Gradient
  internal var center: UnitPoint
  internal var startRadius: CGFloat
  internal var endRadius: CGFloat

  public init(gradient: Gradient, center: UnitPoint, startRadius: CGFloat, endRadius: CGFloat) {
    self.gradient = gradient
    self.center = center
    self.startRadius = startRadius
    self.endRadius = endRadius
  }

  public init(colors: [Color], center: UnitPoint, startRadius: CGFloat, endRadius: CGFloat) {
    self.init(
      gradient: Gradient(colors: colors), center: center,
      startRadius: startRadius, endRadius: endRadius
    )
  }

  public init(stops: [Gradient.Stop], center: UnitPoint, startRadius: CGFloat, endRadius: CGFloat) {
    self.init(
      gradient: Gradient(stops: stops), center: center,
      startRadius: startRadius, endRadius: endRadius
    )
  }

  public typealias Body = _ShapeView<Rectangle, Self>

  public func _apply(to shape: inout _ShapeStyle_Shape) {
    shape.result = .resolved(
      .gradient(
        gradient,
        style: .radial(center: center, startRadius: startRadius, endRadius: endRadius)
      )
    )
  }

  public static func _apply(to type: inout _ShapeStyle_ShapeType) {}
}

@frozen public struct EllipticalGradient: ShapeStyle, View {
  internal var gradient: Gradient
  internal var center: UnitPoint
  internal var startRadiusFraction: CGFloat
  internal var endRadiusFraction: CGFloat

  public init(
    gradient: Gradient,
    center: UnitPoint = .center,
    startRadiusFraction: CGFloat = 0,
    endRadiusFraction: CGFloat = 0.5
  ) {
    self.gradient = gradient
    self.center = center
    self.startRadiusFraction = startRadiusFraction
    self.endRadiusFraction = endRadiusFraction
  }

  public init(
    colors: [Color],
    center: UnitPoint = .center,
    startRadiusFraction: CGFloat = 0,
    endRadiusFraction: CGFloat = 0.5
  ) {
    self.init(
      gradient: .init(colors: colors),
      center: center,
      startRadiusFraction: startRadiusFraction,
      endRadiusFraction: endRadiusFraction
    )
  }

  public init(
    stops: [Gradient.Stop],
    center: UnitPoint = .center,
    startRadiusFraction: CGFloat = 0,
    endRadiusFraction: CGFloat = 0.5
  ) {
    self.init(
      gradient: .init(stops: stops),
      center: center,
      startRadiusFraction: startRadiusFraction,
      endRadiusFraction: endRadiusFraction
    )
  }

  public typealias Body = _ShapeView<Rectangle, Self>

  public func _apply(to shape: inout _ShapeStyle_Shape) {
    shape.result = .resolved(
      .gradient(
        gradient,
        style: .elliptical(
          center: center,
          startRadiusFraction: startRadiusFraction,
          endRadiusFraction: endRadiusFraction
        )
      )
    )
  }

  public static func _apply(to type: inout _ShapeStyle_ShapeType) {}
}

@frozen public struct AngularGradient: ShapeStyle, View {
  internal var gradient: Gradient
  internal var center: UnitPoint
  internal var startAngle: Angle
  internal var endAngle: Angle

  public init(
    gradient: Gradient,
    center: UnitPoint,
    startAngle: Angle = .zero,
    endAngle: Angle = .zero
  ) {
    self.gradient = gradient
    self.center = center
    self.startAngle = startAngle
    self.endAngle = endAngle
  }

  public init(colors: [Color], center: UnitPoint, startAngle: Angle, endAngle: Angle) {
    self.init(
      gradient: Gradient(colors: colors),
      center: center,
      startAngle: startAngle,
      endAngle: endAngle
    )
  }

  public init(stops: [Gradient.Stop], center: UnitPoint, startAngle: Angle, endAngle: Angle) {
    self.init(
      gradient: Gradient(stops: stops),
      center: center,
      startAngle: startAngle,
      endAngle: endAngle
    )
  }

  public init(gradient: Gradient, center: UnitPoint, angle: Angle = .zero) {
    self.init(gradient: gradient, center: center, startAngle: angle, endAngle: angle)
  }

  public init(colors: [Color], center: UnitPoint, angle: Angle = .zero) {
    self.init(
      gradient: Gradient(colors: colors),
      center: center,
      angle: angle
    )
  }

  public init(stops: [Gradient.Stop], center: UnitPoint, angle: Angle = .zero) {
    self.init(
      gradient: Gradient(stops: stops),
      center: center,
      angle: angle
    )
  }

  public typealias Body = _ShapeView<Rectangle, Self>

  public func _apply(to shape: inout _ShapeStyle_Shape) {
    shape.result = .resolved(
      .gradient(
        gradient,
        style: .angular(center: center, startAngle: startAngle, endAngle: endAngle)
      )
    )
  }

  public static func _apply(to type: inout _ShapeStyle_ShapeType) {}
}

public extension ShapeStyle where Self == LinearGradient {
  static func linearGradient(
    _ gradient: Gradient,
    startPoint: UnitPoint,
    endPoint: UnitPoint
  ) -> LinearGradient {
    .init(gradient: gradient, startPoint: startPoint, endPoint: endPoint)
  }

  static func linearGradient(colors: [Color], startPoint: UnitPoint,
                             endPoint: UnitPoint) -> LinearGradient
  {
    .init(colors: colors, startPoint: startPoint, endPoint: endPoint)
  }

  static func linearGradient(stops: [Gradient.Stop], startPoint: UnitPoint,
                             endPoint: UnitPoint) -> LinearGradient
  {
    .init(stops: stops, startPoint: startPoint, endPoint: endPoint)
  }
}

public extension ShapeStyle where Self == RadialGradient {
  static func radialGradient(
    _ gradient: Gradient,
    center: UnitPoint,
    startRadius: CGFloat,
    endRadius: CGFloat
  ) -> RadialGradient {
    .init(
      gradient: gradient, center: center,
      startRadius: startRadius, endRadius: endRadius
    )
  }

  static func radialGradient(
    colors: [Color],
    center: UnitPoint,
    startRadius: CGFloat,
    endRadius: CGFloat
  ) -> RadialGradient {
    .init(
      colors: colors, center: center,
      startRadius: startRadius, endRadius: endRadius
    )
  }

  static func radialGradient(
    stops: [Gradient.Stop],
    center: UnitPoint,
    startRadius: CGFloat,
    endRadius: CGFloat
  ) -> RadialGradient {
    .init(
      stops: stops, center: center,
      startRadius: startRadius, endRadius: endRadius
    )
  }
}

public extension ShapeStyle where Self == EllipticalGradient {
  static func ellipticalGradient(
    _ gradient: Gradient,
    center: UnitPoint = .center,
    startRadiusFraction: CGFloat = 0,
    endRadiusFraction: CGFloat = 0.5
  ) -> EllipticalGradient {
    .init(
      gradient: gradient, center: center,
      startRadiusFraction: startRadiusFraction,
      endRadiusFraction: endRadiusFraction
    )
  }

  static func ellipticalGradient(
    colors: [Color],
    center: UnitPoint = .center,
    startRadiusFraction: CGFloat = 0,
    endRadiusFraction: CGFloat = 0.5
  ) -> EllipticalGradient {
    .init(
      colors: colors, center: center,
      startRadiusFraction: startRadiusFraction,
      endRadiusFraction: endRadiusFraction
    )
  }

  static func ellipticalGradient(
    stops: [Gradient.Stop],
    center: UnitPoint = .center,
    startRadiusFraction: CGFloat = 0,
    endRadiusFraction: CGFloat = 0.5
  ) -> EllipticalGradient {
    .init(
      stops: stops, center: center,
      startRadiusFraction: startRadiusFraction,
      endRadiusFraction: endRadiusFraction
    )
  }
}

public extension ShapeStyle where Self == AngularGradient {
  static func angularGradient(
    _ gradient: Gradient,
    center: UnitPoint,
    startAngle: Angle,
    endAngle: Angle
  ) -> AngularGradient {
    .init(
      gradient: gradient, center: center,
      startAngle: startAngle, endAngle: endAngle
    )
  }

  static func angularGradient(
    colors: [Color],
    center: UnitPoint,
    startAngle: Angle,
    endAngle: Angle
  ) -> AngularGradient {
    .init(
      colors: colors, center: center,
      startAngle: startAngle, endAngle: endAngle
    )
  }

  static func angularGradient(
    stops: [Gradient.Stop],
    center: UnitPoint,
    startAngle: Angle,
    endAngle: Angle
  ) -> AngularGradient {
    .init(
      stops: stops, center: center,
      startAngle: startAngle, endAngle: endAngle
    )
  }
}

public extension ShapeStyle where Self == AngularGradient {
  static func conicGradient(
    _ gradient: Gradient,
    center: UnitPoint,
    angle: Angle = .zero
  ) -> AngularGradient {
    .init(gradient: gradient, center: center, angle: angle)
  }

  static func conicGradient(
    colors: [Color],
    center: UnitPoint,
    angle: Angle = .zero
  ) -> AngularGradient {
    .init(colors: colors, center: center, angle: angle)
  }

  static func conicGradient(
    stops: [Gradient.Stop],
    center: UnitPoint,
    angle: Angle = .zero
  ) -> AngularGradient {
    .init(stops: stops, center: center, angle: angle)
  }
}
