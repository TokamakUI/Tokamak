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
//  Created by Carson Katri on 7/3/20.
//

import Foundation

public struct _RotationEffect: GeometryEffect {
  public var angle: Angle
  public var anchor: UnitPoint

  public init(angle: Angle, anchor: UnitPoint = .center) {
    self.angle = angle
    self.anchor = anchor
  }

  public func effectValue(size: CGSize) -> ProjectionTransform {
    .init(CGAffineTransform.identity.rotated(by: CGFloat(angle.radians)))
  }

  public func body(content: Content) -> some View {
    content
  }

  public var animatableData: AnimatablePair<Angle.AnimatableData, UnitPoint.AnimatableData> {
    get {
      .init(angle.animatableData, anchor.animatableData)
    }
    set {
      (angle.animatableData, anchor.animatableData) = newValue[]
    }
  }
}

public extension View {
  func rotationEffect(_ angle: Angle, anchor: UnitPoint = .center) -> some View {
    modifier(_RotationEffect(angle: angle, anchor: anchor))
  }
}
