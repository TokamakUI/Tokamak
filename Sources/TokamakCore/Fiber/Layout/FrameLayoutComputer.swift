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

/// A `LayoutComputer` that fills its parent.
final class FrameLayoutComputer: LayoutComputer {
  let proposedSize: CGSize
  let width: CGFloat?
  let height: CGFloat?
  let alignment: Alignment

  init(proposedSize: CGSize, width: CGFloat?, height: CGFloat?, alignment: Alignment) {
    self.proposedSize = proposedSize
    self.width = width
    self.height = height
    self.alignment = alignment
  }

  func proposeSize<V>(for child: V, at index: Int, in context: LayoutContext) -> CGSize
    where V: View
  {
    .init(width: width ?? proposedSize.width, height: height ?? proposedSize.height)
  }

  func position(_ child: LayoutContext.Child, in context: LayoutContext) -> CGPoint {
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

  func requestSize(in context: LayoutContext) -> CGSize {
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
  static func _makeView(_ inputs: ViewInputs<_FrameLayout>) -> ViewOutputs {
    .init(inputs: inputs, layoutComputer: { FrameLayoutComputer(
      proposedSize: $0,
      width: inputs.content.width,
      height: inputs.content.height,
      alignment: inputs.content.alignment
    ) })
  }
}
