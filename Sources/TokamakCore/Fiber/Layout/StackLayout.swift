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
//  Created by Carson Katri on 5/24/22.
//

import Foundation

private extension ViewDimensions {
  /// Access the guide value of an `Alignment` for a particular `Axis`.
  subscript(alignment alignment: Alignment, in axis: Axis) -> CGFloat {
    switch axis {
    case .horizontal: return self[alignment.vertical]
    case .vertical: return self[alignment.horizontal]
    }
  }
}

/// The `Layout.Cache` for `StackLayout` conforming types.
@_spi(TokamakCore)
public struct StackLayoutCache {
  /// The widest/tallest (depending on the `axis`) subview.
  /// Used to place subviews along the `alignment`.
  var maxSubview: ViewDimensions?

  /// The ideal size for each subview as computed in `sizeThatFits`.
  var idealSizes = [CGSize]()
}

/// An internal structure used to store layout information about
/// `LayoutSubview`s of a `StackLayout` that will later be sorted
private struct MeasuredSubview {
  let view: LayoutSubview
  let index: Int
  let min: CGSize
  let max: CGSize
  let infiniteMainAxis: Bool
  let spacing: CGFloat
}

/// The protocol all built-in stacks conform to.
/// Provides a shared implementation for stack layout logic.
@_spi(TokamakCore)
public protocol StackLayout: Layout where Cache == StackLayoutCache {
  /// The direction of this stack. `vertical` for `VStack`, `horizontal` for `HStack`.
  static var orientation: Axis { get }

  /// The full `Alignment` with an ignored value for the main axis.
  var _alignment: Alignment { get }

  var spacing: CGFloat? { get }
}

@_spi(TokamakCore)
public extension StackLayout {
  static var layoutProperties: LayoutProperties {
    var properties = LayoutProperties()
    properties.stackOrientation = Self.orientation
    return properties
  }

  /// The `CGSize` component for the current `axis`.
  ///
  /// A `vertical` axis will return `height`.
  /// A `horizontal` axis will return `width`.
  static var mainAxis: WritableKeyPath<CGSize, CGFloat> {
    switch Self.orientation {
    case .vertical: return \.height
    case .horizontal: return \.width
    }
  }

  /// The `CGSize` component for the axis opposite `axis`.
  ///
  /// A `vertical` axis will return `width`.
  /// A `horizontal` axis will return `height`.
  static var crossAxis: WritableKeyPath<CGSize, CGFloat> {
    switch Self.orientation {
    case .vertical: return \.width
    case .horizontal: return \.height
    }
  }

  func makeCache(subviews: Subviews) -> Cache {
    // Ensure we have enough space in `idealSizes` for each subview.
    .init(maxSubview: nil, idealSizes: Array(repeating: .zero, count: subviews.count))
  }

  func updateCache(_ cache: inout Cache, subviews: Subviews) {
    cache.maxSubview = nil
    // Ensure we have enough space in `idealSizes` for each subview.
    cache.idealSizes = Array(repeating: .zero, count: subviews.count)
  }

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
    let proposal = proposal.replacingUnspecifiedDimensions()

    /// The minimum size of each `View` on the main axis.
    var minSize = CGFloat.zero

    /// The aggregate `ViewSpacing` distances.
    var totalSpacing = CGFloat.zero

    /// The number of `View`s with a given priority.
    var priorityCount = [Double: Int]()

    /// The aggregate minimum size of each `View` with a given priority.
    var prioritySize = [Double: CGFloat]()
    let measuredSubviews = subviews.enumerated().map { index, view -> MeasuredSubview in
      priorityCount[view.priority, default: 0] += 1

      var minProposal = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
      minProposal[keyPath: Self.crossAxis] = proposal[keyPath: Self.crossAxis]
      minProposal[keyPath: Self.mainAxis] = 0
      /// The minimum size for this subview along the `mainAxis`.
      /// Uses `dimensions(in:)` to collect the alignment guides for use in `placeSubviews`.
      let min = view.dimensions(in: .init(minProposal))

      // Aggregate the minimum size of the stack for the combined subviews.
      minSize += min.size[keyPath: Self.mainAxis]

      // Aggregate the minimum size of this priority to divvy up space later.
      prioritySize[view.priority, default: 0] += min.size[keyPath: Self.mainAxis]

      var maxProposal = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
      maxProposal[keyPath: Self.crossAxis] = minProposal[keyPath: Self.crossAxis]
      /// The maximum size for this subview along the `mainAxis`.
      let max = view.sizeThatFits(.init(maxProposal))

      /// The spacing around this `View` and its previous (if it is not first).
      let spacing: CGFloat
      if subviews.indices.contains(index - 1) {
        if let overrideSpacing = self.spacing {
          spacing = overrideSpacing
        } else {
          spacing = subviews[index - 1].spacing.distance(to: view.spacing, along: Self.orientation)
        }
      } else {
        spacing = .zero
      }
      // Aggregate all spacing values.
      totalSpacing += spacing

      // If this `View` is the widest, save it to the cache for access in `placeSubviews`.
      if min.size[keyPath: Self.crossAxis] > cache.maxSubview?.size[keyPath: Self.crossAxis]
        ?? .zero
      {
        cache.maxSubview = min
      }

      return MeasuredSubview(
        view: view,
        index: index,
        min: min.size,
        max: max,
        infiniteMainAxis: max[keyPath: Self.mainAxis] == .infinity,
        spacing: spacing
      )
    }

    // Calculate ideal sizes for each View based on their min/max sizes and the space available.
    var available = proposal[keyPath: Self.mainAxis] - minSize - totalSpacing
    // The final resulting size.
    var size = CGSize.zero
    size[keyPath: Self.crossAxis] = cache.maxSubview?.size[keyPath: Self.crossAxis] ?? .zero
    for subview in measuredSubviews.sorted(by: {
      // Sort by priority descending.
      if $0.view.priority == $1.view.priority {
        // If the priorities match, allow non-flexible `View`s to size first.
        return $1.infiniteMainAxis && !$0.infiniteMainAxis
      } else {
        return $0.view.priority > $1.view.priority
      }
    }) {
      // The amount of space available to `View`s with this priority value.
      let priorityAvailable = available + prioritySize[subview.view.priority, default: 0]
      // The number of `View`s with this priority value remaining as a `CGFloat`.
      let priorityRemaining = CGFloat(priorityCount[subview.view.priority, default: 1])
      // Propose the full `crossAxis`, but only the remaining `mainAxis`.
      // Divvy up the available space between each remaining `View` with this priority value.
      var divviedSize = proposal
      divviedSize[keyPath: Self.mainAxis] = priorityAvailable / priorityRemaining
      let idealSize = subview.view.sizeThatFits(.init(divviedSize))
      cache.idealSizes[subview.index] = idealSize
      size[keyPath: Self.mainAxis] += idealSize[keyPath: Self.mainAxis] + subview.spacing
      // Remove our `idealSize` from the `available` space.
      available -= idealSize[keyPath: Self.mainAxis]
      // Decrement the number of `View`s left with this priority so space can be evenly divided
      // between the remaining `View`s.
      priorityCount[subview.view.priority, default: 1] -= 1
    }
    return size
  }

  func spacing(subviews: Subviews, cache: inout Cache) -> ViewSpacing {
    subviews.reduce(into: .zero) { $0.formUnion($1.spacing) }
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) {
    // The current progress along the `mainAxis`.
    var position = CGFloat.zero
    // The offset of the `_alignment` in the `maxSubview`,
    // used as the reference point for alignments along this axis.
    let alignmentOffset = cache.maxSubview?[alignment: _alignment, in: Self.orientation] ?? .zero
    for (index, view) in subviews.enumerated() {
      // Add a gap for the spacing distance from the previous subview to this one.
      let spacing: CGFloat
      if subviews.indices.contains(index - 1) {
        if let overrideSpacing = self.spacing {
          spacing = overrideSpacing
        } else {
          spacing = subviews[index - 1].spacing.distance(to: view.spacing, along: Self.orientation)
        }
      } else {
        spacing = .zero
      }
      position += spacing

      let proposal = ProposedViewSize(cache.idealSizes[index])
      let size = view.dimensions(in: proposal)

      // Offset the placement along the `crossAxis` to align with the
      // `alignment` of the `maxSubview`.
      var placement = CGSize(width: bounds.minX, height: bounds.minY)
      placement[keyPath: Self.mainAxis] += position
      placement[keyPath: Self.crossAxis] += alignmentOffset
        - size[alignment: _alignment, in: Self.orientation]

      view.place(
        at: .init(
          x: placement.width,
          y: placement.height
        ),
        proposal: proposal
      )
      // Move further along the stack's `mainAxis`.
      position += size.size[keyPath: Self.mainAxis]
    }
  }
}

@_spi(TokamakCore)
extension VStack: StackLayout {
  public static var orientation: Axis { .vertical }
  public var _alignment: Alignment { .init(horizontal: alignment, vertical: .center) }
}

@_spi(TokamakCore)
extension HStack: StackLayout {
  public static var orientation: Axis { .horizontal }
  public var _alignment: Alignment { .init(horizontal: .center, vertical: alignment) }
}
