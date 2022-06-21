// Copyright 2022 Tokamak contributors
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
//  Created by Carson Katri on 6/20/22.
//

import Foundation

/// The preferred spacing around a `View`.
///
/// When computing spacing in a custom `Layout`, use `distance(to:along:)`
/// to find the smallest spacing needed to accommodate the preferences
/// of the `View`s you are aligning.
public struct ViewSpacing {
  private var top: CGFloat
  private var leading: CGFloat
  private var bottom: CGFloat
  private var trailing: CGFloat

  public static let zero: ViewSpacing = .init()

  public init() {
    top = 8
    leading = 8
    bottom = 8
    trailing = 8
  }

  public mutating func formUnion(_ other: ViewSpacing, edges: Edge.Set = .all) {
    if edges.contains(.top) {
      top = max(top, other.top)
    }
    if edges.contains(.leading) {
      leading = max(leading, other.leading)
    }
    if edges.contains(.bottom) {
      bottom = max(bottom, other.bottom)
    }
    if edges.contains(.trailing) {
      trailing = max(trailing, other.trailing)
    }
  }

  public func union(_ other: ViewSpacing, edges: Edge.Set = .all) -> ViewSpacing {
    var spacing = self
    spacing.formUnion(other, edges: edges)
    return spacing
  }

  /// The smallest spacing that accommodates the preferences of `self` and `next`.
  public func distance(to next: ViewSpacing, along axis: Axis) -> CGFloat {
    // Assume `next` comes after `self` either horizontally or vertically.
    switch axis {
    case .horizontal:
      return max(trailing, next.leading)
    case .vertical:
      return max(bottom, next.top)
    }
  }
}
