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
public struct RadialGradient: ShapeStyle, View {
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
