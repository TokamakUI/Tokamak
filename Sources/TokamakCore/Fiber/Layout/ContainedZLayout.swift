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

/// The cache for a `ContainedZLayout`.
@_spi(TokamakCore)
public struct ContainedZLayoutCache {
  /// The result of `dimensions(in:)` for the primary subview.
  var primaryDimensions: ViewDimensions?
}

/// A layout that fits secondary subviews to the size of a primary subview.
///
/// Used to implement `_BackgroundLayout` and `_OverlayLayout`.
@_spi(TokamakCore)
public protocol ContainedZLayout: Layout where Cache == ContainedZLayoutCache {
  var alignment: Alignment { get }
  /// An accessor for the primary subview from a `LayoutSubviews` collection.
  static var primarySubview: KeyPath<LayoutSubviews, LayoutSubview?> { get }
}

@_spi(TokamakCore)
public extension ContainedZLayout {
  func makeCache(subviews: Subviews) -> Cache {
    .init()
  }

  func spacing(subviews: LayoutSubviews, cache: inout Cache) -> ViewSpacing {
    subviews[keyPath: Self.primarySubview]?.spacing ?? .init()
  }

  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) -> CGSize {
    // Assume the dimensions of the primary subview.
    cache.primaryDimensions = subviews[keyPath: Self.primarySubview]?.dimensions(in: proposal)
    return .init(
      width: cache.primaryDimensions?.width ?? .zero,
      height: cache.primaryDimensions?.height ?? .zero
    )
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) {
    let proposal = ProposedViewSize(bounds.size)

    // Place the foreground at the origin.
    subviews[keyPath: Self.primarySubview]?.place(at: bounds.origin, proposal: proposal)

    let backgroundSubviews = subviews[keyPath: Self.primarySubview] == subviews.first
      ? subviews.dropFirst(1)
      : subviews.dropLast(1)

    /// The `ViewDimensions` of the subview with the greatest `width`, used to follow `alignment`.
    var widest: ViewDimensions?
    /// The `ViewDimensions` of the subview with the greatest `height`.
    var tallest: ViewDimensions?

    let dimensions = backgroundSubviews.map { subview -> ViewDimensions in
      let dimensions = subview.dimensions(in: proposal)
      if dimensions.width > (widest?.width ?? .zero) {
        widest = dimensions
      }
      if dimensions.height > (tallest?.height ?? .zero) {
        tallest = dimensions
      }
      return dimensions
    }

    /// The alignment guide values of the primary subview.
    let primaryOffset = CGSize(
      width: cache.primaryDimensions?[alignment.horizontal] ?? .zero,
      height: cache.primaryDimensions?[alignment.vertical] ?? .zero
    )
    /// The alignment guide values of the secondary subviews (background/overlay).
    /// Uses the widest/tallest element to get the full extents.
    let secondaryOffset = CGSize(
      width: widest?[alignment.horizontal] ?? .zero,
      height: tallest?[alignment.vertical] ?? .zero
    )
    /// The center offset of the secondary subviews.
    let secondaryCenter = CGSize(
      width: widest?[HorizontalAlignment.center] ?? .zero,
      height: tallest?[VerticalAlignment.center] ?? .zero
    )
    /// The origin of the secondary subviews with alignment.
    let secondaryOrigin = CGPoint(
      x: bounds.minX + primaryOffset.width - secondaryOffset.width + secondaryCenter.width,
      y: bounds.minY + primaryOffset.height - secondaryOffset.height + secondaryCenter.height
    )
    for (index, subview) in backgroundSubviews.enumerated() {
      // Background elements are centered between each other, but placed with `alignment`
      // all together on the foreground.
      subview.place(
        at: .init(
          x: secondaryOrigin.x - dimensions[index][HorizontalAlignment.center],
          y: secondaryOrigin.y - dimensions[index][VerticalAlignment.center]
        ),
        proposal: proposal
      )
    }
  }
}

/// Expects the primary subview to be last.
@_spi(TokamakCore)
extension _BackgroundLayout: ContainedZLayout {
  public static var primarySubview: KeyPath<LayoutSubviews, LayoutSubview?> { \.last }
}

/// Expects the primary subview to be the first.
@_spi(TokamakCore)
extension _OverlayLayout: ContainedZLayout {
  public static var primarySubview: KeyPath<LayoutSubviews, LayoutSubview?> { \.first }
}
