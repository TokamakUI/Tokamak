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
  /// The `View` type this `ViewSpacing` is for.
  /// Some `View`s prefer different spacing based on the `View` they are adjacent to.
  @_spi(TokamakCore)
  public var viewType: Any.Type?

  private var top: (ViewSpacing) -> CGFloat
  private var leading: (ViewSpacing) -> CGFloat
  private var bottom: (ViewSpacing) -> CGFloat
  private var trailing: (ViewSpacing) -> CGFloat

  public static let zero: ViewSpacing = .init(
    viewType: nil,
    top: { _ in 0 },
    leading: { _ in 0 },
    bottom: { _ in 0 },
    trailing: { _ in 0 }
  )

  /// Create a `ViewSpacing` instance with default values.
  public init() {
    self.init(viewType: nil)
  }

  @_spi(TokamakCore)
  public static let defaultValue: CGFloat = 8

  @_spi(TokamakCore)
  public init(
    viewType: Any.Type?,
    top: @escaping (ViewSpacing) -> CGFloat = { _ in Self.defaultValue },
    leading: @escaping (ViewSpacing) -> CGFloat = { _ in Self.defaultValue },
    bottom: @escaping (ViewSpacing) -> CGFloat = { _ in Self.defaultValue },
    trailing: @escaping (ViewSpacing) -> CGFloat = { _ in Self.defaultValue }
  ) {
    self.viewType = viewType
    self.top = top
    self.leading = leading
    self.bottom = bottom
    self.trailing = trailing
  }

  public mutating func formUnion(_ other: ViewSpacing, edges: Edge.Set = .all) {
    if viewType != other.viewType {
      viewType = nil
    }
    if edges.contains(.top) {
      let current = top
      top = { max(current($0), other.top($0)) }
    }
    if edges.contains(.leading) {
      let current = leading
      leading = { max(current($0), other.leading($0)) }
    }
    if edges.contains(.bottom) {
      let current = bottom
      bottom = { max(current($0), other.bottom($0)) }
    }
    if edges.contains(.trailing) {
      let current = trailing
      trailing = { max(current($0), other.trailing($0)) }
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
      return max(trailing(next), next.leading(self))
    case .vertical:
      return max(bottom(next), next.top(self))
    }
  }
}
