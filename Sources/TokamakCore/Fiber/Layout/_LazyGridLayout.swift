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
//  Created by Carson Katri on 7/6/22.
//

import Foundation

@_spi(TokamakCore)
public struct _LazyGridLayoutCache {
  var resolvedItems = [ResolvedItem]()
  var mainAxisSizes = [CGFloat]()
  struct ResolvedItem {
    let size: CGFloat
    let item: GridItem
  }
}

@_spi(TokamakCore)
public protocol _LazyGridLayout: Layout where Cache == _LazyGridLayoutCache {
  static var axis: Axis { get }
  var items: [GridItem] { get }
  var _alignment: Alignment { get }
  var spacing: CGFloat? { get }
}

public extension _LazyGridLayout {
  internal var mainAxis: WritableKeyPath<CGSize, CGFloat> {
    switch Self.axis {
    case .horizontal:
      return \.width
    case .vertical:
      return \.height
    }
  }

  internal var crossAxis: WritableKeyPath<CGSize, CGFloat> {
    switch Self.axis {
    case .horizontal:
      return \.height
    case .vertical:
      return \.width
    }
  }

  func makeCache(subviews: Subviews) -> Cache {
    .init()
  }

  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) -> CGSize {
    cache.resolvedItems.removeAll()

    var reservedFixedSpace = CGFloat.zero
    for (index, item) in items.enumerated() {
      if case .adaptive = item.size {
        continue
      }
      if index < items.count - 1 {
        reservedFixedSpace += item.spacing ?? 8
      }
      if case let .fixed(fixed) = item.size {
        reservedFixedSpace += fixed
      }
    }

    let proposal = proposal.replacingUnspecifiedDimensions()

    var remainingSize = proposal[keyPath: crossAxis] - reservedFixedSpace

    let flexibleItems = items.filter {
      if case .fixed = $0.size {
        return false
      } else {
        return true
      }
    }
    var remainingItems = flexibleItems.count

    for item in items {
      switch item.size {
      case let .flexible(minimum, maximum):
        let divviedSpace = remainingSize / CGFloat(remainingItems)
        let size = max(minimum, min(maximum, divviedSpace))
        remainingSize -= size
        cache.resolvedItems.append(.init(size: size, item: item))
        remainingItems -= 1
      case let .fixed(size):
        cache.resolvedItems.append(.init(size: size, item: item))
      case let .adaptive(minimum, maximum):
        let divviedSpace = remainingSize / CGFloat(remainingItems)
        var remaining = divviedSpace
        var fitCount = 0
        while true {
          if fitCount != 0 {
            remaining -= item.spacing ?? 8
          }
          if remaining - minimum < 0 {
            break
          }
          remaining -= minimum
          fitCount += 1
        }
        let fitSize = min(
          max(
            (divviedSpace - ((item.spacing ?? 8) * CGFloat(fitCount - 1))) / CGFloat(fitCount),
            minimum
          ),
          maximum
        )
        for _ in 0..<fitCount {
          remainingSize -= fitSize
          cache.resolvedItems.append(.init(size: fitSize, item: item))
        }
        remainingItems -= 1
      }
    }

    var mainAxisSize = CGFloat.zero
    var maxMainAxisSize = CGFloat.zero
    var mainAxisSpacing = CGFloat.zero
    for (index, subview) in subviews.enumerated() {
      let itemIndex = index % cache.resolvedItems.count
      let itemSize = cache.resolvedItems[itemIndex].size
      let size = subview.sizeThatFits(.init(
        width: Self.axis == .vertical ? itemSize : nil,
        height: Self.axis == .horizontal ? itemSize : nil
      ))
      if size[keyPath: mainAxis] > maxMainAxisSize {
        maxMainAxisSize = size[keyPath: mainAxis]
      }
      if subviews.indices.contains(index + cache.resolvedItems.count) {
        if let spacing = spacing {
          mainAxisSpacing = spacing
        } else {
          let spacing = subview.spacing.distance(
            to: subviews[index + cache.resolvedItems.count].spacing,
            along: .vertical
          )
          if spacing > mainAxisSpacing {
            mainAxisSpacing = spacing
          }
        }
      }
      if itemIndex == cache.resolvedItems.count - 1 {
        cache.mainAxisSizes.append(maxMainAxisSize)
        mainAxisSize += maxMainAxisSize + mainAxisSpacing
        maxMainAxisSize = .zero
        mainAxisSpacing = .zero
      }
    }
    cache.mainAxisSizes.append(maxMainAxisSize)
    mainAxisSize += maxMainAxisSize

    var result = proposal
    result[keyPath: mainAxis] = mainAxisSize
    return result
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) {
    let contentSize = cache.resolvedItems.enumerated().reduce(into: .zero) {
      $0 += $1.element
        .size + ($1.offset == cache.resolvedItems.count - 1 ? 0 : $1.element.item.spacing ?? 8)
    }

    var offset = CGSize.zero
    let origin = CGSize(width: bounds.width, height: bounds.height)
    let contentAlignmentID: AlignmentID.Type
    switch Self.axis {
    case .horizontal:
      contentAlignmentID = _alignment.vertical.id
    case .vertical:
      contentAlignmentID = _alignment.horizontal.id
    }
    let startOffset = contentAlignmentID.defaultValue(
      in: .init(size: origin, alignmentGuides: [:])
    ) - contentAlignmentID.defaultValue(
      in: .init(size: .init(width: contentSize, height: contentSize), alignmentGuides: [:])
    )
    offset[keyPath: crossAxis] = startOffset
    var mainAxisSpacing = CGFloat.zero
    for (index, subview) in subviews.enumerated() {
      let itemIndex = index % cache.resolvedItems.count
      let mainAxisIndex = index / cache.resolvedItems.count

      if itemIndex == 0 {
        offset[keyPath: crossAxis] = startOffset
        mainAxisSpacing = .zero
      }

      var proposal = CGSize.zero
      proposal[keyPath: mainAxis] = cache.mainAxisSizes[mainAxisIndex]
      proposal[keyPath: crossAxis] = cache.resolvedItems[itemIndex].size

      let dimensions = subview.dimensions(in: .init(proposal))

      var position = offset

      position.width += cache.resolvedItems[itemIndex].item.alignment.horizontal.id
        .defaultValue(in: .init(
          size: proposal,
          alignmentGuides: [:]
        ))
      position.height += cache.resolvedItems[itemIndex].item.alignment.vertical.id
        .defaultValue(in: .init(
          size: proposal,
          alignmentGuides: [:]
        ))

      position.width -= dimensions[
        cache.resolvedItems[itemIndex].item.alignment.horizontal
      ]
      position.height -= dimensions[
        cache.resolvedItems[itemIndex].item.alignment.vertical
      ]

      subview.place(
        at: .init(
          x: bounds.minX + position.width,
          y: bounds.minY + position.height
        ),
        proposal: .init(proposal)
      )

      offset[keyPath: crossAxis] += cache.resolvedItems[itemIndex].size
      offset[keyPath: crossAxis] += cache.resolvedItems[itemIndex].item.spacing ?? 8

      if spacing == nil && subviews.indices.contains(index + cache.resolvedItems.count) {
        let spacing = subview.spacing.distance(
          to: subviews[index + cache.resolvedItems.count].spacing,
          along: Self.axis
        )
        if spacing > mainAxisSpacing {
          mainAxisSpacing = spacing
        }
      }
      if itemIndex == cache.resolvedItems.count - 1 {
        offset[keyPath: mainAxis] += cache.mainAxisSizes[mainAxisIndex] + (
          spacing ?? mainAxisSpacing
        )
      }
    }
  }
}

@_spi(TokamakCore)
extension LazyVGrid: _LazyGridLayout {
  public static var axis: Axis { .vertical }
  public var items: [GridItem] { columns }
  public var _alignment: Alignment { .init(horizontal: alignment, vertical: .center) }
}

@_spi(TokamakCore)
extension LazyHGrid: _LazyGridLayout {
  public static var axis: Axis { .horizontal }
  public var items: [GridItem] { rows }
  public var _alignment: Alignment { .init(horizontal: .center, vertical: alignment) }
}
