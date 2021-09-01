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
//  Created by Carson Katri on 6/28/20.
//

import Foundation

public struct UnitPoint: Hashable {
  public var x: CGFloat
  public var y: CGFloat

  public init() {
    self.init(x: 0, y: 0)
  }

  public init(x: CGFloat, y: CGFloat) {
    self.x = x
    self.y = y
  }

  public static let zero: UnitPoint = .init()
  public static let center: UnitPoint = .init(x: 0.5, y: 0.5)
  public static let leading: UnitPoint = .init(x: 0, y: 0.5)
  public static let trailing: UnitPoint = .init(x: 1, y: 0.5)
  public static let top: UnitPoint = .init(x: 0.5, y: 0)
  public static let bottom: UnitPoint = .init(x: 0.5, y: 1)
  public static let topLeading: UnitPoint = .init(x: 0, y: 0)
  public static let topTrailing: UnitPoint = .init(x: 1, y: 0)
  public static let bottomLeading: UnitPoint = .init(x: 0, y: 1)
  public static let bottomTrailing: UnitPoint = .init(x: 1, y: 1)
}

extension UnitPoint: Animatable {
  public var animatableData: AnimatablePair<CGFloat, CGFloat> {
    get {
      .init(x, y)
    }
    set {
      (x, y) = newValue[]
    }
  }
}
