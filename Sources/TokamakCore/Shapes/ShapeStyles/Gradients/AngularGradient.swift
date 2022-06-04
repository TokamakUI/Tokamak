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
//  Created by Carson Katri on 8/7/21.
//

import Foundation

@frozen
public struct AngularGradient: ShapeStyle, View {
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
    self.init(
      gradient: gradient,
      center: center,
      startAngle: angle,
      endAngle: angle + .degrees(360)
    )
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
