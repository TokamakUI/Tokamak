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

@frozen
public struct Gradient: Equatable {
  @frozen
  public struct Stop: Equatable {
    public var color: Color
    public var location: CGFloat

    public init(color: Color, location: CGFloat) {
      self.color = color
      self.location = location.isNaN ? .zero : location
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
