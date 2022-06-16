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
//  Created by Carson Katri on 5/24/22.
//

import Foundation

///// A `LayoutComputer` that constrains a background to a foreground.
// final class BackgroundLayoutComputer: LayoutComputer {
//  let proposedSize: CGSize
//  let alignment: Alignment
//
//  init(proposedSize: CGSize, alignment: Alignment) {
//    self.proposedSize = proposedSize
//    self.alignment = alignment
//  }
//
//  func proposeSize<V>(for child: V, at index: Int, in context: LayoutContext) -> CGSize
//    where V: View
//  {
//    if index == 0 {
//      // The foreground can pick their size.
//      return proposedSize
//    } else {
//      // The background is constrained to the foreground.
//      return context.children.first?.dimensions.size ?? .zero
//    }
//  }
//
//  func position(_ child: LayoutContext.Child, in context: LayoutContext) -> CGPoint {
//    let foregroundSize = ViewDimensions(
//      size: .init(
//        width: context.children.first?.dimensions.width ?? 0,
//        height: context.children.first?.dimensions.height ?? 0
//      ),
//      alignmentGuides: [:]
//    )
//    return .init(
//      x: foregroundSize[alignment.horizontal] - child.dimensions[alignment.horizontal],
//      y: foregroundSize[alignment.vertical] - child.dimensions[alignment.vertical]
//    )
//  }
//
//  func requestSize(in context: LayoutContext) -> CGSize {
//    let childSize = context.children.reduce(CGSize.zero) {
//      .init(
//        width: max($0.width, $1.dimensions.width),
//        height: max($0.height, $1.dimensions.height)
//      )
//    }
//    return .init(width: childSize.width, height: childSize.height)
//  }
// }
//
// public extension _BackgroundLayout {
//  static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
//    .init(
//      inputs: inputs,
//      layoutComputer: {
//        BackgroundLayoutComputer(proposedSize: $0, alignment: inputs.content.alignment)
//      }
//    )
//  }
// }
//
// public extension _BackgroundStyleModifier {
//  static func _makeView(_ inputs: ViewInputs<Self>) -> ViewOutputs {
//    .init(
//      inputs: inputs,
//      layoutComputer: { BackgroundLayoutComputer(proposedSize: $0, alignment: .center) }
//    )
//  }
// }

extension _BackgroundLayout: Layout {
  public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) -> CGSize {
    subviews.first?.sizeThatFits(proposal) ?? .zero
  }

  public func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    for subview in subviews {
      subview.place(
        at: bounds.origin,
        proposal: .init(width: bounds.width, height: bounds.height)
      )
    }
  }
}
