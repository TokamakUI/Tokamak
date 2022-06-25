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

/// A `Layout` container that creates a frame with constraints.
///
/// The children are proposed the full proposal given to this container
/// clamped to the specified minimum and maximum values.
///
/// Then the children are placed with `alignment` in the container.
private struct FlexFrameLayout: Layout {
  let minWidth: CGFloat?
  let idealWidth: CGFloat?
  let maxWidth: CGFloat?
  let minHeight: CGFloat?
  let idealHeight: CGFloat?
  let maxHeight: CGFloat?
  let alignment: Alignment

  struct Cache {
    var dimensions = [ViewDimensions]()
  }

  func makeCache(subviews: Subviews) -> Cache {
    .init()
  }

  func updateCache(_ cache: inout Cache, subviews: Subviews) {
    cache.dimensions.removeAll()
  }

  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) -> CGSize {
    let bounds = CGSize(
      width: min(
        max(minWidth ?? .zero, proposal.width ?? idealWidth ?? .zero),
        maxWidth ?? CGFloat.infinity
      ),
      height: min(
        max(minHeight ?? .zero, proposal.height ?? idealHeight ?? .zero),
        maxHeight ?? CGFloat.infinity
      )
    )
    let proposal = ProposedViewSize(bounds)

    var subviewSizes = CGSize.zero
    cache.dimensions = subviews.map { subview -> ViewDimensions in
      let dimensions = subview.dimensions(in: proposal)
      if dimensions.width > subviewSizes.width {
        subviewSizes.width = dimensions.width
      }
      if dimensions.height > subviewSizes.height {
        subviewSizes.height = dimensions.height
      }
      return dimensions
    }

    var size = CGSize.zero
    if let minWidth = minWidth,
       bounds.width < subviewSizes.width
    {
      size.width = max(bounds.width, minWidth)
    } else if let maxWidth = maxWidth,
              bounds.width > subviewSizes.width
    {
      size.width = min(bounds.width, maxWidth)
    } else {
      size.width = subviewSizes.width
    }
    if let minHeight = minHeight,
       bounds.height < subviewSizes.height
    {
      size.height = max(bounds.height, minHeight)
    } else if let maxHeight = maxHeight,
              bounds.height > subviewSizes.height
    {
      size.height = min(bounds.height, maxHeight)
    } else {
      size.height = subviewSizes.height
    }

    return size
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) {
    let proposal = ProposedViewSize(bounds.size)
    let frameDimensions = ViewDimensions(
      size: .init(width: bounds.width, height: bounds.height),
      alignmentGuides: [:]
    )

    for (index, subview) in subviews.enumerated() {
      subview.place(
        at: .init(
          x: bounds.minX + frameDimensions[alignment.horizontal]
            - cache.dimensions[index][alignment.horizontal],
          y: bounds.minY + frameDimensions[alignment.vertical]
            - cache.dimensions[index][alignment.vertical]
        ),
        proposal: proposal
      )
    }
  }
}

public extension _FlexFrameLayout {
  func _visitChildren<V>(_ visitor: V, content: Content) where V: ViewVisitor {
    visitor.visit(FlexFrameLayout(
      minWidth: minWidth, idealWidth: idealWidth, maxWidth: maxWidth,
      minHeight: minHeight, idealHeight: idealHeight, maxHeight: maxHeight,
      alignment: alignment
    ).callAsFunction {
      content
    })
  }
}
