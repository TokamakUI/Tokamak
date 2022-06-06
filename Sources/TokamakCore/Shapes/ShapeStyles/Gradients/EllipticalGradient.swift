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
public struct EllipticalGradient: ShapeStyle, View {
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
