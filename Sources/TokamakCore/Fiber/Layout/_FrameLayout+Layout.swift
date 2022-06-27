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
//  Created by Carson Katri on 5/28/22.
//

import Foundation

/// A `Layout` container that requests a specific size on one or more axes.
///
/// The container proposes the constrained size to its children,
/// then places them with `alignment` in the constrained bounds.
///
/// Children request their own size, so they may overflow this container.
///
/// If no fixed size is specified for a an axis, the container will use the size of its children.
private struct FrameLayout: Layout {
  let width: CGFloat?
  let height: CGFloat?
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
    var size = CGSize.zero
    let proposal = ProposedViewSize(
      width: width ?? proposal.width,
      height: height ?? proposal.height
    )
    cache.dimensions = subviews.map { subview -> ViewDimensions in
      let dimensions = subview.dimensions(in: proposal)
      if dimensions.width > size.width {
        size.width = dimensions.width
      }
      if dimensions.height > size.height {
        size.height = dimensions.height
      }
      return dimensions
    }
    return .init(
      width: width ?? size.width,
      height: height ?? size.height
    )
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

public extension _FrameLayout {
  func _visitChildren<V>(_ visitor: V, content: Content) where V: ViewVisitor {
    visitor.visit(FrameLayout(width: width, height: height, alignment: alignment).callAsFunction {
      content
    })
  }
}
