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
public struct LinearGradient: ShapeStyle, View {
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

public extension ShapeStyle where Self == LinearGradient {
  static func linearGradient(
    _ gradient: Gradient,
    startPoint: UnitPoint,
    endPoint: UnitPoint
  ) -> LinearGradient {
    .init(gradient: gradient, startPoint: startPoint, endPoint: endPoint)
  }

  static func linearGradient(
    colors: [Color],
    startPoint: UnitPoint,
    endPoint: UnitPoint
  ) -> LinearGradient {
    .init(colors: colors, startPoint: startPoint, endPoint: endPoint)
  }

  static func linearGradient(
    stops: [Gradient.Stop],
    startPoint: UnitPoint,
    endPoint: UnitPoint
  ) -> LinearGradient {
    .init(stops: stops, startPoint: startPoint, endPoint: endPoint)
  }
}
