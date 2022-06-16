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

struct StackLayoutCache {
  var largestSubview: LayoutSubview?
  var minSize: CGFloat
  var flexibleSubviews: Int
}

protocol StackLayout: Layout where Cache == StackLayoutCache {
  static var orientation: Axis { get }
  var stackAlignment: Alignment { get }
  var spacing: CGFloat? { get }
}

private extension ViewDimensions {
  subscript(alignment alignment: Alignment, in axis: Axis) -> CGFloat {
    switch axis {
    case .horizontal: return self[alignment.vertical]
    case .vertical: return self[alignment.horizontal]
    }
  }
}

extension StackLayout {
  public static var layoutProperties: LayoutProperties {
    var properties = LayoutProperties()
    properties.stackOrientation = orientation
    return properties
  }

  public func makeCache(subviews: Subviews) -> Cache {
    .init(
      largestSubview: nil,
      minSize: .zero,
      flexibleSubviews: 0
    )
  }

  static var mainAxis: WritableKeyPath<CGSize, CGFloat> {
    switch orientation {
    case .vertical: return \.height
    case .horizontal: return \.width
    }
  }

  static var crossAxis: WritableKeyPath<CGSize, CGFloat> {
    switch orientation {
    case .vertical: return \.width
    case .horizontal: return \.height
    }
  }

  public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) -> CGSize {
    cache.largestSubview = subviews
      .map { ($0, $0.sizeThatFits(proposal)) }
      .max { a, b in
        a.1[keyPath: Self.crossAxis] < b.1[keyPath: Self.crossAxis]
      }?.0
    let largestSize = cache.largestSubview?.sizeThatFits(proposal) ?? .zero

    var last: Subviews.Element?
    cache.minSize = .zero
    cache.flexibleSubviews = 0
    for subview in subviews {
      let sizeThatFits = subview.sizeThatFits(.infinity)
      if sizeThatFits[keyPath: Self.mainAxis] == .infinity {
        cache.flexibleSubviews += 1
      } else {
        cache.minSize += sizeThatFits[keyPath: Self.mainAxis]
      }
      if let last = last {
        if let spacing = spacing {
          cache.minSize += spacing
        } else {
          cache.minSize += last.spacing.distance(
            to: subview.spacing,
            along: Self.orientation
          )
        }
      }
      last = subview
    }
    var size = CGSize.zero
    if cache.flexibleSubviews > 0 {
      size[keyPath: Self.mainAxis] = max(
        cache.minSize,
        proposal.replacingUnspecifiedDimensions()[keyPath: Self.mainAxis]
      )
      size[keyPath: Self.crossAxis] = largestSize[keyPath: Self.crossAxis]
    } else {
      size[keyPath: Self.mainAxis] = cache.minSize
      size[keyPath: Self.crossAxis] = largestSize[keyPath: Self.crossAxis] == .infinity
        ? proposal.replacingUnspecifiedDimensions()[keyPath: Self.crossAxis]
        : largestSize[keyPath: Self.crossAxis]
    }
    return size
  }

  public func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) {
    var last: Subviews.Element?
    var offset = CGFloat.zero
    let alignmentOffset = cache.largestSubview?
      .dimensions(in: proposal)[alignment: stackAlignment, in: Self.orientation] ?? .zero
    let flexibleSize = (bounds.size[keyPath: Self.mainAxis] - cache.minSize) /
      CGFloat(cache.flexibleSubviews)
    for subview in subviews {
      if let last = last {
        if let spacing = spacing {
          offset += spacing
        } else {
          offset += last.spacing.distance(to: subview.spacing, along: Self.orientation)
        }
      }

      let dimensions = subview.dimensions(
        in: .init(
          width: Self.orientation == .horizontal ? .infinity : bounds.width,
          height: Self.orientation == .vertical ? .infinity : bounds.height
        )
      )
      var position = CGSize(width: bounds.minX, height: bounds.minY)
      position[keyPath: Self.mainAxis] += offset
      position[keyPath: Self.crossAxis] += alignmentOffset - dimensions[
        alignment: stackAlignment,
        in: Self.orientation
      ]
      var size = CGSize.zero
      size[keyPath: Self.mainAxis] = dimensions.size[keyPath: Self.mainAxis] == .infinity
        ? flexibleSize
        : bounds.size[keyPath: Self.mainAxis]
      size[keyPath: Self.crossAxis] = bounds.size[keyPath: Self.crossAxis]
      subview.place(
        at: .init(x: position.width, y: position.height),
        proposal: .init(width: size.width, height: size.height)
      )

      if dimensions.size[keyPath: Self.mainAxis] == .infinity {
        offset += flexibleSize
      } else {
        offset += dimensions.size[keyPath: Self.mainAxis]
      }
      last = subview
    }
  }
}

extension VStack: StackLayout {
  public static var orientation: Axis { .vertical }
  public var stackAlignment: Alignment { .init(horizontal: alignment, vertical: .center) }
}

extension HStack: StackLayout {
  public static var orientation: Axis { .horizontal }
  public var stackAlignment: Alignment { .init(horizontal: .center, vertical: alignment) }
}
