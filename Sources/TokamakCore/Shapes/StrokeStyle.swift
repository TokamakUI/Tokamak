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
//  Created by Carson Katri on 7/22/20.
//

import Foundation

#if canImport(CoreGraphics)
import CoreGraphics
#endif

public struct StrokeStyle: Equatable {
  public var lineWidth: CGFloat
  public var lineCap: CGLineCap
  public var lineJoin: CGLineJoin
  public var miterLimit: CGFloat
  public var dash: [CGFloat]
  public var dashPhase: CGFloat

  public init(
    lineWidth: CGFloat = 1,
    lineCap: CGLineCap = .butt,
    lineJoin: CGLineJoin = .miter,
    miterLimit: CGFloat = 10,
    dash: [CGFloat] = [CGFloat](),
    dashPhase: CGFloat = 0
  ) {
    self.lineWidth = lineWidth
    self.lineCap = lineCap
    self.lineJoin = lineJoin
    self.miterLimit = miterLimit
    self.dash = dash
    self.dashPhase = dashPhase
  }
}

extension StrokeStyle: Animatable {
  public var animatableData: AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>> {
    get {
      .init(lineWidth, .init(miterLimit, dashPhase))
    }
    set {
      lineWidth = newValue[].0
      miterLimit = newValue[].1[].0
      dashPhase = newValue[].1[].1
    }
  }
}
