// Copyright 2021 Tokamak contributors
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

/// A `LayoutComputer` that uses a specified size in one or more axes.
@_spi(TokamakCore) public final class FrameLayoutComputer: LayoutComputer {
  let proposedSize: CGSize
  let width: CGFloat?
  let height: CGFloat?
  let alignment: Alignment

  public init(proposedSize: CGSize, width: CGFloat?, height: CGFloat?, alignment: Alignment) {
    self.proposedSize = proposedSize
    self.width = width
    self.height = height
    self.alignment = alignment
  }

  public func proposeSize<V>(for child: V, at index: Int, in context: LayoutContext) -> CGSize
    where V: View
  {
    .init(width: width ?? proposedSize.width, height: height ?? proposedSize.height)
  }

  public func position(_ child: LayoutContext.Child, in context: LayoutContext) -> CGPoint {
    let size = ViewDimensions(
      size: .init(
        width: width ?? child.dimensions.width,
        height: height ?? child.dimensions.height
      ),
      alignmentGuides: [:]
    )
    return .init(
      x: size[alignment.horizontal] - child.dimensions[alignment.horizontal],
      y: size[alignment.vertical] - child.dimensions[alignment.vertical]
    )
  }

  public func requestSize(in context: LayoutContext) -> CGSize {
    let childSize = context.children.reduce(CGSize.zero) {
      .init(
        width: max($0.width, $1.dimensions.width),
        height: max($0.height, $1.dimensions.height)
      )
    }
    return .init(width: width ?? childSize.width, height: height ?? childSize.height)
  }
}

public extension _FrameLayout {
  static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    .init(inputs: inputs, layoutComputer: { FrameLayoutComputer(
      proposedSize: $0,
      width: inputs.content.width,
      height: inputs.content.height,
      alignment: inputs.content.alignment
    ) })
  }
}

/// A `LayoutComputer` that uses a specified range of sizes in one or more axes.
@_spi(TokamakCore) public final class FlexFrameLayoutComputer: LayoutComputer {
  let proposedSize: CGSize
  let minWidth: CGFloat?
  let idealWidth: CGFloat?
  let maxWidth: CGFloat?
  let minHeight: CGFloat?
  let idealHeight: CGFloat?
  let maxHeight: CGFloat?
  let alignment: Alignment

  public init(
    proposedSize: CGSize,
    minWidth: CGFloat?,
    idealWidth: CGFloat?,
    maxWidth: CGFloat?,
    minHeight: CGFloat?,
    idealHeight: CGFloat?,
    maxHeight: CGFloat?,
    alignment: Alignment
  ) {
    self.proposedSize = proposedSize
    self.minWidth = minWidth
    self.idealWidth = idealWidth
    self.maxWidth = maxWidth
    self.minHeight = minHeight
    self.idealHeight = idealHeight
    self.maxHeight = maxHeight
    self.alignment = alignment
  }

  public func proposeSize<V>(for child: V, at index: Int, in context: LayoutContext) -> CGSize
    where V: View
  {
    .init(
      width: maxWidth ?? proposedSize.width,
      height: maxHeight ?? proposedSize.height
    )
  }

  public func position(_ child: LayoutContext.Child, in context: LayoutContext) -> CGPoint {
    let size = ViewDimensions(
      size: .init(
        width: min(maxWidth ?? .infinity, max(minWidth ?? 0, child.dimensions.width)),
        height: min(maxHeight ?? .infinity, max(minHeight ?? 0, child.dimensions.height))
      ),
      alignmentGuides: [:]
    )
    return .init(
      x: size[alignment.horizontal] - child.dimensions[alignment.horizontal],
      y: size[alignment.vertical] - child.dimensions[alignment.vertical]
    )
  }

  public func requestSize(in context: LayoutContext) -> CGSize {
    let childSize = context.children.reduce(CGSize.zero) {
      .init(
        width: max($0.width, $1.dimensions.width),
        height: max($0.height, $1.dimensions.height)
      )
    }
    return .init(
      width: min(maxWidth ?? .infinity, max(minWidth ?? 0, childSize.width)),
      height: min(maxHeight ?? .infinity, max(minHeight ?? 0, childSize.height))
    )
  }
}

public extension _FlexFrameLayout {
  static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
    .init(inputs: inputs, layoutComputer: { FlexFrameLayoutComputer(
      proposedSize: $0,
      minWidth: inputs.content.minWidth,
      idealWidth: inputs.content.idealWidth,
      maxWidth: inputs.content.maxWidth,
      minHeight: inputs.content.minHeight,
      idealHeight: inputs.content.idealHeight,
      maxHeight: inputs.content.maxHeight,
      alignment: inputs.content.alignment
    ) })
  }
}
