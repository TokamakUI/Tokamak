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

/// A `LayoutComputer` that aligns `Views` along a specified `Axis`
/// with a given spacing and alignment.
///
/// The specified main `Axis` will fit to the combined width/height (depending on the axis)
/// of the children.
/// The cross axis will fit to the child with the largest height/width.
struct StackLayoutComputer: LayoutComputer {
  let proposedSize: CGSize
  let axis: Axis
  let alignment: Alignment
  let spacing: CGFloat

  init(proposedSize: CGSize, axis: Axis, alignment: Alignment, spacing: CGFloat) {
    self.proposedSize = proposedSize
    self.axis = axis
    self.alignment = alignment
    self.spacing = spacing
  }

  func proposeSize<V>(for child: V, at index: Int, in context: LayoutContext) -> CGSize
    where V: View
  {
    let used = context.children.reduce(CGSize.zero) {
      .init(
        width: $0.width + $1.dimensions.width,
        height: $0.height + $1.dimensions.height
      )
    }
    switch axis {
    case .horizontal:
      return .init(
        width: proposedSize.width - used.width,
        height: proposedSize.height
      )
    case .vertical:
      return .init(
        width: proposedSize.width,
        height: proposedSize.height - used.height
      )
    }
  }

  func position(_ child: LayoutContext.Child, in context: LayoutContext) -> CGPoint {
    let (maxSize, fitSize) = context.children
      .enumerated()
      .reduce((CGSize.zero, CGSize.zero)) { res, next in
        (
          .init(
            width: max(res.0.width, next.element.dimensions.width),
            height: max(res.0.height, next.element.dimensions.height)
          ),
          next.offset < child.index ? .init(
            width: res.1.width + next.element.dimensions.width,
            height: res.1.height + next.element.dimensions.height
          ) : res.1
        )
      }
    let maxDimensions = ViewDimensions(size: maxSize, alignmentGuides: [:])
    /// The gaps up to this point.
    let fitSpacing = CGFloat(child.index) * spacing
    switch axis {
    case .horizontal:
      return .init(
        x: fitSize.width + fitSpacing,
        y: maxDimensions[alignment.vertical] - child.dimensions[alignment.vertical]
      )
    case .vertical:
      return .init(
        x: maxDimensions[alignment.horizontal] - child.dimensions[alignment.horizontal],
        y: fitSize.height + fitSpacing
      )
    }
  }

  func requestSize(in context: LayoutContext) -> CGSize {
    let maxDimensions = CGSize(
      width: context.children
        .max(by: { $0.dimensions.width < $1.dimensions.width })?.dimensions.width ?? .zero,
      height: context.children
        .max(by: { $0.dimensions.height < $1.dimensions.height })?.dimensions.height ?? .zero
    )
    let fitDimensions = context.children
      .reduce(CGSize.zero) {
        .init(width: $0.width + $1.dimensions.width, height: $0.height + $1.dimensions.height)
      }

    /// The combined gap size.
    let fitSpacing = CGFloat(context.children.count - 1) * spacing

    switch axis {
    case .horizontal:
      return .init(
        width: fitDimensions.width + fitSpacing,
        height: maxDimensions.height
      )
    case .vertical:
      return .init(
        width: maxDimensions.width,
        height: fitDimensions.height + fitSpacing
      )
    }
  }
}

public extension VStack {
  static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    .init(
      inputs: inputs,
      layoutComputer: { proposedSize in
        StackLayoutComputer(
          proposedSize: proposedSize,
          axis: .vertical,
          alignment: .init(horizontal: inputs.content.alignment, vertical: .center),
          spacing: inputs.content.spacing
        )
      }
    )
  }
}

public extension HStack {
  static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    .init(
      inputs: inputs,
      layoutComputer: { proposedSize in
        StackLayoutComputer(
          proposedSize: proposedSize,
          axis: .horizontal,
          alignment: .init(horizontal: .center, vertical: inputs.content.alignment),
          spacing: inputs.content.spacing
        )
      }
    )
  }
}
